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

```bash
    bin/query -m gpt-4 "Create an sr.yaml that searches pubmed for lauryl sulfate and labels conditions."
    INFO:llama_index.token_counter.token_counter:> [query] Total LLM token usage: 1138 tokens
    INFO:llama_index.token_counter.token_counter:> [query] Total embedding token usage: 20 tokens
    Here is an example of an sr.yaml file that searches PubMed for "lauryl sulfate" and labels the documents with a categorical label for conditions:

    ```yaml
    reviewer: mailto:user@example.com

    labels:
      condition:
        question: Condition
        type: categorical
        categories:
          - Condition A
          - Condition B
          - Condition C

      include:
        json-schema: boolean
        question: Include?
        required: true

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
            labels: [include, condition]
            port: 5005
    ```

    This sr.yaml file defines a reviewer's email address, creates a categorical label for conditions with three example categories, and a boolean label for inclusion. It also defines two flows: one for searching PubMed with the query "lauryl sulfate" and another for labeling the documents with the defined labels.
```


### Train

```
nix flake update
bin/train
```
