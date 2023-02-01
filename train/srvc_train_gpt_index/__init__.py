from gpt_index import GPTSimpleVectorIndex, SimpleDirectoryReader
import argparse

def main():
  parser = argparse.ArgumentParser(description='Create a gpt_index file based on a directory')
  parser.add_argument('source_dir', type=str)
  parser.add_argument('index_file', type=str)
  args = parser.parse_args()

  documents = SimpleDirectoryReader(args.source_dir, recursive=True).load_data()
  index = GPTSimpleVectorIndex(documents)
  index.save_to_disk(args.index_file)
