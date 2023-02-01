from gpt_index import GPTSimpleVectorIndex, SimpleDirectoryReader
import argparse

def main():
  parser = argparse.ArgumentParser(description='Query GPT using a gpt_index file')
  parser.add_argument('index_file', type=str)
  parser.add_argument('query', type=str)
  args = parser.parse_args()

  index = GPTSimpleVectorIndex.load_from_disk(args.index_file)
  print(index.query(args.query))
