from gpt_index import GPTSimpleVectorIndex, LLMPredictor, SimpleDirectoryReader
from langchain import OpenAI
import argparse

def main():
  parser = argparse.ArgumentParser(description='Create a gpt_index file based on a directory')
  parser.add_argument('source_dir', type=str)
  parser.add_argument('index_file', type=str)
  args = parser.parse_args()

  documents = SimpleDirectoryReader(args.source_dir, recursive=True).load_data()
  llm_predictor = LLMPredictor(llm=OpenAI(temperature=0, model_name="gpt-3.5-turbo", max_tokens=2048))
  index = GPTSimpleVectorIndex(documents, llm_predictor=llm_predictor)
  index.save_to_disk(args.index_file)
