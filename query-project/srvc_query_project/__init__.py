from gpt_index import Document, GPTSimpleVectorIndex, SimpleDirectoryReader
from openai.error import RateLimitError
from tenacity import RetryError
import argparse, json, os, sys, time, yaml

def create_or_update(index, doc):
  if index.docstore.document_exists(doc.doc_id):
    index.update(doc)
  else:
    index.insert(doc)

def load_project_index(args):
  try:
    index = GPTSimpleVectorIndex.load_from_disk(args.project_index_file)
  except FileNotFoundError:
    index = GPTSimpleVectorIndex.load_from_disk(args.docs_index_file)

  project_path = os.path.abspath(args.project_dir)
  sr_yaml_path = os.path.join(project_path, 'sr.yaml')
  with open(sr_yaml_path, 'r') as f:
    sr_yaml_text = f.read()
    sr_yaml = yaml.safe_load(sr_yaml_text)

  create_or_update(index, Document('The following is the sr.yaml file for the current project in ' + project_path + ':\n' + sr_yaml_text, doc_id='current-project-sr.yaml'))

  sink_path = os.path.join(project_path, sr_yaml.get('db', 'sink.jsonl'))
  event_counts = {}
  try:
    with open(sink_path, 'r') as f:
      i = 0
      for line in f:
        line = line.strip()
        if line:
          event = json.loads(line)
          event_counts[event['type']] = event_counts.get(event['type'], 0) + 1
          if event.get('uri'):
            doc_id = event['uri']
          else:
            doc_id = event['hash']
          if not index.docstore.document_exists(doc_id):
            index.insert(Document('The following is an event in the current project in the file ' + sink_path + ':\n' + line, doc_id=doc_id))
            i += 1
            if (i % 100) == 0:
              index.save_to_disk(args.project_index_file)
  except FileNotFoundError:
    None

  doc_sum = 'The following is summary information for the current project in ' + project_path + ':\n'

  for event_type in ['control', 'document', 'label', 'label-answer']:
    doc_sum += 'There are ' + str(event_counts.get(event_type, 0)) + ' ' + event_type + ' events\n'

  create_or_update(index, Document(doc_sum, doc_id='current-project-summary'))

  index.save_to_disk(args.project_index_file)

  return index

def main():
  parser = argparse.ArgumentParser(description='Query GPT about an SRVC project')
  parser.add_argument('docs_index_file', metavar="docs-index-file", type=str)
  parser.add_argument('--project-dir', dest="project_dir", type=str, default=".")
  parser.add_argument('--project-index-file', dest="project_index_file", type=str, default="srvc-gpt-index.json")
  args = parser.parse_args()
  index = load_project_index(args)

  while True:
    for line in sys.stdin:
      line = line.strip()
      if line:
        request = json.loads(line)
        response = index.query(request['query'])
        print(json.dumps({'response': str(response).strip()}))
