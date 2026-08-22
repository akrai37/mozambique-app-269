#!/usr/bin/env python3
"""Build practice quizzes for categories that have vocabulary but no quiz.

Nine of the twelve vocabulary categories shipped with no practice at all,
including `numbers`, the largest category in the app at 32 words. A learner
could study every one of them and never be tested.

Nothing new has to be drawn or recorded. A quiz question here is an image, a
spoken prompt, and three spoken options - and every vocabulary word already has
an image, a Portuguese word and its own audio. The only thing missing is the
question prompt, which is synthesised locally with macOS `say` using Joana
(pt_PT). European Portuguese matters: Mozambique uses it, not Brazilian.

Output:
  assets/audio/quiz_prompts/*.mp3      question prompts
  assets/json/generated_quiz.json      the quiz definitions

Writing those definitions to Firestore is a separate step (push_quizzes.py), so
the output can be inspected before anything leaves the machine.

Deterministic: same input, same questions, same order. Re-running does not
churn the content.
"""

import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VOCAB = os.path.join(ROOT, 'assets/json/vocab_words.slim.json')
EXISTING_QUIZ = os.path.join(ROOT, 'assets/json/practice_quiz.json')
PROMPT_DIR = os.path.join(ROOT, 'assets/audio/quiz_prompts')
OUT_JSON = os.path.join(ROOT, 'assets/json/generated_quiz.json')

VOICE = 'Joana'          # pt_PT
QUESTIONS_PER_CATEGORY = 6
OPTIONS_PER_QUESTION = 3

# A prompt per category, rather than one generic question for everything.
# "O que é isso?" applied to a number or a verb is confusing, and these are
# learners meeting both a new language and a tablet for the first time.
PROMPTS = {
    'animals':             ('Que animal é este?',      'que_animal_e_este'),
    'fruits':              ('Que fruta é esta?',       'que_fruta_e_esta'),
    'vegetables':          ('Que legume é este?',      'que_legume_e_este'),
    'household_items':     ('O que é isso?',           'o_que_e_isso'),
    'kitchen_items':       ('O que é isso?',           'o_que_e_isso'),
    'professions':         ('Qual é a profissão?',     'qual_e_a_profissao'),
    'numbers':             ('Que número é este?',      'que_numero_e_este'),
    'common_actions':      ('O que está a fazer?',     'o_que_esta_a_fazer'),
    'everyday_activities': ('O que está a fazer?',     'o_que_esta_a_fazer'),
}


def synthesise(text, slug):
    """Render one prompt to mp3. Skips work if the file already exists."""
    mp3 = os.path.join(PROMPT_DIR, f'{slug}.mp3')
    if os.path.exists(mp3):
        return mp3

    os.makedirs(PROMPT_DIR, exist_ok=True)
    aiff = mp3.replace('.mp3', '.aiff')

    subprocess.run(['say', '-v', VOICE, '-o', aiff, text], check=True)
    # -V 4 keeps these small; they are a few seconds of speech, not music.
    subprocess.run(['lame', '--quiet', '-V', '4', aiff, mp3], check=True)
    os.remove(aiff)
    return mp3


def build_questions(category, words):
    """One question per chosen word, with distractors from the same category.

    Distractors come from the same category on purpose. Asking someone to pick
    'Cabra' out of {Cabra, Vermelho, Sete} tests nothing - the answer is
    guessable from the category alone. Same-category options mean the learner
    has to actually know the word.
    """
    prompt_text, prompt_slug = PROMPTS[category]
    total = len(words)
    if total < OPTIONS_PER_QUESTION:
        return []

    # Evenly spaced rather than the first N, so a long category like numbers
    # samples across its range instead of only testing 0-5.
    count = min(QUESTIONS_PER_CATEGORY, total)
    step = max(1, total // count)
    chosen = [i * step for i in range(count) if i * step < total]

    questions = []
    for order, index in enumerate(chosen):
        correct = words[index]

        # Deterministic neighbours, so re-running produces identical content.
        distractors = [words[(index + offset) % total]
                       for offset in range(1, OPTIONS_PER_QUESTION)]

        options = [correct] + distractors
        # Rotate by order so the right answer is not always first.
        pivot = order % len(options)
        options = options[pivot:] + options[:pivot]

        questions.append({
            'slug': f'{prompt_slug}_{order}',
            'order': order,
            'questionText': prompt_text,
            'imagePath': correct['imagePath'],
            'audioPath': f'audio/quiz_prompts/{prompt_slug}.mp3',
            'answers': [
                {
                    'answerText': word['portuguese'],
                    'audioPath': word['audioPath'],
                    'isCorrect': word['portuguese'] == correct['portuguese'],
                }
                for word in options
            ],
        })

    return questions


def main():
    vocab = json.load(open(VOCAB))
    existing = set(json.load(open(EXISTING_QUIZ)))

    missing = sorted(set(vocab) - existing)
    print(f'categories with vocabulary : {len(vocab)}')
    print(f'already have a quiz        : {sorted(existing)}')
    print(f'to generate                : {missing}\n')

    for text, slug in sorted(set(PROMPTS.values())):
        synthesise(text, slug)
        print(f'  prompt  {slug}.mp3  "{text}"')
    print()

    generated = {}
    for category in missing:
        if category not in PROMPTS:
            print(f'  SKIP {category}: no prompt defined')
            continue

        questions = build_questions(category, vocab[category])
        if questions:
            generated[category] = questions
        print(f'  {category:<22} {len(questions)} questions '
              f'from {len(vocab[category])} words')

    json.dump(generated, open(OUT_JSON, 'w'), ensure_ascii=False, indent=1)

    total = sum(len(q) for q in generated.values())
    print(f'\nwrote {OUT_JSON}')
    print(f'{total} new questions across {len(generated)} categories')
    return 0


if __name__ == '__main__':
    sys.exit(main())
