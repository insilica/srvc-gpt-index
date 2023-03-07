## srvc-gpt-index

Query GPT about [SRVC](https://docs.syrev.com) docs and projects.

Requires a valid `OPENAI_API_KEY`.

### Query

```bash
bin/query "What is an srvc project?"
> [query] Total LLM token usage: 927 tokens
> [query] Total embedding token usage: 7 tokens

An SRVC project is a document review system that uses an sr.yaml configuration file to specify labels, review flows, and other parameters. It allows for collaboration between reviewers by using a git repository for the project directory and merging sink files.
```

```bash
bin/query "Create an sr.yaml that searches pubmed for lauryl sulfate and labels conditions. Omit code-block."
> [query] Total LLM token usage: 1002 tokens
> [query] Total embedding token usage: 26 tokens

reviewer: mailto:user@example.com

labels:
  condition:
    question: Condition
    type: categorical
    categories:
      - A
      - B
      - C

flows:
  pubmed-search:
    steps:
      - uses: github:insilica/srvc-pubmed-search
        query: lauryl sulfate

  label:
    steps:
      - run-embedded: generator sink.jsonl

      - run-embedded: remove-reviewed

      - run-embedded: label-web
        labels: [condition]
        port: 5005
```

### Train

```
nix flake update
bin/train
```
