from llama_index import GPTSimpleVectorIndex, LLMPredictor, SimpleDirectoryReader
from llama_index.langchain_helpers.chatgpt import ChatGPTLLMPredictor
from langchain import OpenAI
from langchain.chat_models import ChatOpenAI
from langchain.llms import OpenAIChat
import argparse

def main():
  parser = argparse.ArgumentParser(description='Query GPT using a gpt_index file')
  parser.add_argument('index_file', type=str)
  parser.add_argument('query', type=str)
  parser.add_argument('-m', '--model', type=str, default='gpt-3.5-turbo')
  args = parser.parse_args()

  llm_predictor = LLMPredictor(llm=ChatOpenAI(temperature=0, model_name=args.model))
  index = GPTSimpleVectorIndex.load_from_disk(args.index_file, llm_predictor=llm_predictor)
  print(index.query(args.query))
