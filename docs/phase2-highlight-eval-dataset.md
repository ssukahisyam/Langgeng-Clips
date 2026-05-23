# Phase 2 Highlight Eval Dataset

Raw videos stay outside the repository. This manifest tracks the minimum 10-sample ground-truth set used to compare prompt variants.

| Sample ID | Source label | Duration | Ground-truth ranges | Notes |
|---|---|---:|---|---|
| eval-001 | podcast-hook | 12m | 00:42-01:05, 07:10-07:36 | Strong hook + payoff |
| eval-002 | tutorial-tip | 9m | 02:14-02:46 | Practical how-to moment |
| eval-003 | gaming-clutch | 18m | 05:20-05:52, 13:04-13:38 | Peak gameplay moments |
| eval-004 | talking-head-story | 15m | 03:30-04:05 | Story conflict and punchline |
| eval-005 | product-demo | 8m | 01:12-01:40, 06:18-06:45 | Feature reveal |
| eval-006 | interview-answer | 22m | 10:44-11:24 | Concise standalone answer |
| eval-007 | reaction | 11m | 04:05-04:31 | Emotional reaction |
| eval-008 | education | 14m | 08:12-08:48 | Clear concept explanation |
| eval-009 | livestream | 25m | 15:20-15:58 | Spontaneous funny moment |
| eval-010 | mixed-language | 10m | 02:30-03:02 | ID/EN mixed caption sample |

For each run, record the prompt variant, model, chosen ranges, score, and whether a tester marked the output usable.
