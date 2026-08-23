# Decisions and Feedback Log

A record of the judgement calls, the feedback that changed direction, and the
bugs found by using the app rather than by reading the code.

Kept separately from [CHANGES.md](CHANGES.md), which records *what* changed.
This one records *why*, and who pushed for it.

---

## 1. Feedback that changed the product

### The professor: "you will need Firebase"

The first proposal was to drop Firebase and run the app entirely on Hive. That
came from a practical place — there were no credentials, the app could not be
built, and every piece of content turned out to already be committed to the
repository.

The feedback was that Firebase is not optional here: the media lives in Firebase
Storage, and there would be authentication to think about.

**What was done with it — not simply obeyed.** The Firebase direction was taken,
but the local work was kept rather than thrown away. The app now has three
content modes behind one flag:

| Mode | Text | Media |
|---|---|---|
| Local | bundled | bundled |
| Hybrid | Firestore | bundled |
| Full Firebase | Firestore | Storage |

Keeping local mode turned out to matter for reasons that had nothing to do with
the original argument. It is what made the app runnable before any credentials
existed, it is what makes development fast, and it is the fallback that made
hybrid mode possible when Storage turned out to be unreachable from a browser.

**What was deliberately not followed: the login.** See section 3 — the learners
share one tablet and cannot read a sign-in screen. Group identity was built
instead: the tablet knows which group is using it, a moderator picks from a
list, and nobody types a password.

**Following the feedback is what surfaced two real problems.** Pointing the app
at live Firebase exposed the Storage CORS gap and, when pushing the work,
GitHub's scanner found a Firebase Admin SDK key sitting in the repository's
history. Neither would have been found by reading the code — they only appear
when you actually connect to the thing.

### The quiz needed a reset, and I had it filed as minor

I listed "no way to retry a quiz" under **smaller things** in an analysis. The
feedback was that it mattered more than that, and it did:

- Repetition is how the vocabulary sticks; taking a quiz once is worth little.
- One tablet passes between groups, and the next group should not start on the
  previous group's answers.
- The capability technically existed — leaving the screen and returning resets
  it, because the state is in memory — but it was completely undiscoverable.
  For a user who cannot read, undiscoverable means nonexistent.

Built as `Reiniciar ⟲`, deliberately matching the reset button that practice
conversations already had, so the two read as the same action. → `26e6621`

### "Will the tick always be there?"

Asked after finishing a quiz and seeing the completion badge persist. It
surfaced a design hole: completion was permanent, with no way to clear it for a
new group. A second group picking up the tablet would see the first group's
ticks and start on a screen that looked half finished.

That question is what produced group-scoped progress. → `b8d6c7e`

### "So the previous teacher has to manually erase it?"

A follow-up about the actual workflow, which exposed two more problems with the
one-way "new group" button I had just built:

1. A group meeting Monday might return Wednesday, and there was no way back to
   them — every session would start a new id and fragment their history.
2. A moderator in a hurry has to *remember* to press the button. Forgetting
   silently merges two groups' records.

Replaced with a picker: choose who is here today from a list. Choosing is much
harder to forget than remembering. → `1282931`

Explicit reasoning given for spending the extra time: *"if it's going to be used
by actual users then it should be worth it."*

### "I see the tick from the previous group unless I go to practice and come back"

A bug found by using the app, not by testing it. See section 2.

---

## 2. Bugs found by using the app

These are the ones no test would have caught, because the stored data was
correct in every case. Worth separating out — they are the argument for actually
running software rather than only testing it.

| Found by | Bug | Why tests missed it |
|---|---|---|
| Running it on web at all | `InternetAddress.lookup` is `dart:io`, which does not exist in a browser. It threw and killed the entire sync before one document was fetched. | Works fine on Android. Invisible unless you run it somewhere new. |
| Reloading the page | Blank screen — the debug service connection dies on reload. | Tooling behaviour, not app behaviour. |
| Switching groups and looking | Badges kept the previous group's ticks until you navigated somewhere and back. | Data was correct. Only the screen was wrong, and only in one specific sequence. |

The badge one is the sharpest example. The widget listened to a single Hive key,
`{groupId}::{category}`, computed once at build time. Switching groups changes
*which key matters*, so it carried on watching a key that would never fire
again. Every test passed, Hive was right, Firestore was right. → `93133c0`

---

## 3. Things deliberately not built

Deciding not to build something, for a stated reason, is a decision — not an
omission.

**Individual logins / user profiles.** The learners share one tablet and cannot
read a sign-in screen. Accounts would be unusable by the people meant to use
them. Progress is recorded **per group** instead, which is what the deployment
actually looks like: one device, one group, a moderator running the session.

**Moderator authentication.** Considered and dropped. It adds a login flow, a
shared Firebase user pool, and network dependency at sign-in, in exchange for
gating a single sync button. Not worth it.

**A second Firebase project.** My recommendation, overruled — and the constraint
given was *complete separation from the existing developers' work*. Solved
inside the existing project instead: read the existing content collections,
write only to a separate `progress_ankush` collection. Firestore collections are
independent, so this cannot affect what the live app reads.

**Android build.** I raised installing the Android SDK because a downloaded
`google-services.json` is only used for Android builds. Correctly pushed back on
— Android was never in scope, and the browser build was already working. Roughly
20 GB of tooling avoided.

**Full Firebase mode on web.** Abandoned after finding the Storage bucket has no
CORS policy, so browsers refuse the download. Fixing it means changing
infrastructure we do not own. Hybrid mode was built instead: text from Firestore,
media from bundled assets.

---

## 4. Where AI got it wrong

Recorded honestly, because the failures are more instructive than the successes.

**Claimed hybrid mode worked when it had never run.** Reported "zero errors, zero
fallbacks" as success. Zero errors meant zero *attempts* — a populated Hive cache
was short-circuiting the sync, so the app was serving stale local content and
never contacting Firebase. Caught by adding a `FORCE_SYNC` flag and logging that
is actually visible on web. **Absence of failure was read as success.**

**Got the asset verification wrong twice**, reporting 58 missing files that were
not missing. First because the dev server answers `HEAD` with 404, then because
filenames containing spaces need double URL-encoding. Both times the app was
fine and the checker was broken.

**Wrote the badge listener bug**, and specifically commented that scoping to one
key was the efficient choice. It was efficient and incorrect.

**Wrote a `completed` check that was nonsense** — three conditions that collapsed
to one. Caught by re-reading before shipping.

**Raised the Android SDK unprompted**, costing time on something out of scope.

**Overstated a finding for most of the project.** I repeatedly argued the app
"contradicts itself — it teaches non-readers but navigates by text", and built a
navigation panel partly on that basis. Challenged with a simple question — *"it
feels like the same thing that's on the main page, why do we need it?"* — and the
challenge was right twice over. The panel duplicated the home grid, and the grid
**is already picture-first navigation**. The search box is a redundant extra
control, not a barrier.

The claim was corrected in [AUDIT.md](AUDIT.md), the panel was cut from the home
screen, and what remains is described as what it is: a shortcut between
categories. A wrong framing is worse than a missing one, because it justifies
work the product does not need.

**Committed a navigation panel with a second "go home" logo** when the top bar
already had one, placing a discard-this-screen control exactly where a thumb
reaches for Back. The same duplication mistake, twice in one feature.

### How things were verified

- Ran the app rather than trusting logs — the hybrid-mode claim died this way.
- Queried Firestore directly over REST rather than trusting the app's own report.
- Proved the regression tests were real by reimplementing the original buggy
  search expression and confirming it failed them. A regression test that also
  passes against broken code proves nothing.
- Measured rather than assumed: all 489 media references checked, not sampled.

---

## 5. Process notes

**Commits came in batches, not continuously.** The work was done in phases but
not committed as it went, so changes became entangled in shared files —
`database_service.dart` alone carries three phases of work. A truthful
fine-grained history could not be reconstructed after the fact. The commits that
exist are real and accurately described; they are just later than the work.
Worth stating plainly rather than hoping timestamps go unexamined.

**Branch naming.** First attempt was `course-269-improvements`; renamed to
`ankush/app-improvements` on feedback, following the convention of prefixing with
the author.

**Explanations were too long and too dense.** Repeated feedback throughout, and
fair. Shorter answers with fewer caveats were what was actually wanted.

**Work discarded or reversed**, since incremental development is partly about
what you throw away:

- Full-Firebase-on-web, abandoned after the CORS finding
- A quiz filter placed in `build()`, moved to load time after realising it would
  break the rounded-corner logic
- The counter-template test, deleted rather than salvaged
- A scratch test file written to prove the regression tests were real, then
  removed
- Port-hopping to dodge a stale cache, replaced with the `FORCE_SYNC` flag
- The one-way "new group" button, replaced by the picker within an hour

---

## 6. Still open

- **No conversation with an end user or the partner organisation.** There has
  been stakeholder feedback from the professor (section 1), which is real and
  changed the product, but nobody has spoken to a moderator or a learner.

  The one question worth asking: does one person hold the tablet for the whole
  group, or do learners take turns — and does the moderator need to see results
  afterwards? Progress is recorded **per group** on the assumption that a shared
  tablet means group-level is the right unit. That assumption is reasoned, not
  verified. If learners take turns and each wants their own record, the design
  is wrong.

- **9 of 12 categories have no quiz at all**, including `numbers`, which is the
  largest category in the app at 32 words. This is the biggest remaining gap in
  the product, and it is content rather than code.
- **Firestore accepts unauthenticated writes.** Anyone with the API key that
  ships inside the app can write to or delete the live collections. Verified
  with a single throwaway document, deleted immediately. Fixing it is a few lines
  of security rules on the project owner's side.
