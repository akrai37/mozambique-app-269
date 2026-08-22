#!/usr/bin/env python3
"""Upload generated quizzes to a Firestore collection of our own.

Writes to `content_ankush`, never to `app_content` or `dev_content`. Firestore
collections are independent, so nothing here can affect the content the live
app reads. Nothing the original developers run reads this collection either -
the separation holds in both directions.

The layout mirrors the app's own content structure:

  content_ankush/practice_quiz/categories/{category}/quizzes/{slug}

so the existing sync code can read it with almost no change.

Media is not uploaded. Every image and answer clip already ships in the app's
assets, and the generated prompts are bundled alongside them, so these
documents reference files that are already on the device. That also means they
keep working if this collection ever goes away.

Usage:
  python3 tools/generate_quizzes.py   # build the content
  python3 tools/push_quizzes.py       # upload it
  python3 tools/push_quizzes.py --dry-run
"""

import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GENERATED = os.path.join(ROOT, 'assets/json/generated_quiz.json')
PROJECT = 'mozambique-app'
COLLECTION = 'content_ankush'
BASE = f'https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents'

PROTECTED = {'app_content', 'dev_content'}


def api_key():
    src = open(os.path.join(ROOT, 'lib/firebase_options.dart')).read()
    web = re.search(r'static const FirebaseOptions web = FirebaseOptions\((.*?)\);', src, re.S)
    return re.search(r"apiKey:\s*'([^']*)'", web.group(1)).group(1)


def to_firestore(value):
    """Convert a plain Python value into Firestore's typed JSON."""
    if isinstance(value, bool):
        return {'booleanValue': value}
    if isinstance(value, int):
        return {'integerValue': str(value)}
    if isinstance(value, str):
        return {'stringValue': value}
    if isinstance(value, list):
        return {'arrayValue': {'values': [to_firestore(v) for v in value]}}
    if isinstance(value, dict):
        return {'mapValue': {'fields': {k: to_firestore(v) for k, v in value.items()}}}
    if value is None:
        return {'nullValue': None}
    raise TypeError(f'unsupported: {type(value)}')


def write_doc(path, fields, key, dry_run):
    """PATCH creates or replaces a document at an exact path."""
    if any(part in PROTECTED for part in path.split('/')):
        raise SystemExit(f'REFUSING to write to a protected collection: {path}')

    if dry_run:
        print(f'    would write {path}')
        return

    url = f'{BASE}/{urllib.parse.quote(path)}?key={key}'
    body = json.dumps({'fields': {k: to_firestore(v) for k, v in fields.items()}}).encode()
    req = urllib.request.Request(url, method='PATCH', data=body,
                                 headers={'Content-Type': 'application/json'})
    try:
        urllib.request.urlopen(req, timeout=30).read()
    except urllib.error.HTTPError as e:
        raise SystemExit(f'write failed for {path}: {e.code} {e.read()[:300]}')


def main():
    dry_run = '--dry-run' in sys.argv
    key = api_key()
    generated = json.load(open(GENERATED))

    print(f'target     : {COLLECTION}')
    print(f'protected  : {sorted(PROTECTED)} (writes refused)')
    print(f'mode       : {"DRY RUN" if dry_run else "LIVE"}\n')

    written = 0
    for category, questions in sorted(generated.items()):
        # The category document itself: the sync code reads a 'name' field.
        write_doc(f'{COLLECTION}/practice_quiz/categories/{category}',
                  {'name': category}, key, dry_run)

        for question in questions:
            write_doc(
                f'{COLLECTION}/practice_quiz/categories/{category}/quizzes/{question["slug"]}',
                {
                    'slug': question['slug'],
                    'order': question['order'],
                    'questionText': question['questionText'],
                    'imagePath': question['imagePath'],
                    'audioPath': question['audioPath'],
                    'answers': question['answers'],
                },
                key, dry_run)
            written += 1

        print(f'  {category:<22} {len(questions)} questions')

    print(f'\n{written} question documents '
          f'{"planned" if dry_run else "written"} to {COLLECTION}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
