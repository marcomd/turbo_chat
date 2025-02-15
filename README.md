# Turbo chat

![logo.jpg](logo.jpg)

## Introduction

A tutorial to create an AI chat, a clone of ChatGPT (or Claude) but that can also run in your private network and without paying a monthly fee.

https://medium.com/@m.mastrodonato/lets-write-a-free-chatgpt-clone-with-rails-8-part-1-85ee5668d8fb

## Install

Download the source and install the bundle:
```
git clone git@github.com:marcomd/turbo_chat.git

cd turbo_chat

bundle install
```

⚠️ To execute prompts locally you need [ollama](https://ollama.com/download).

To only try the UI (not to develop):

`bin/rails server`

Navigate to http://localhost:3000

---

To develop I suggest you to install foreman to easily get the hot reload:

```
gem install foreman

foreman start -f Procfile.dev
```

Navigate to http://localhost:5100



## Summary

In this first part the application is set up with the basic structure: 

- Part 1
  - authentication
  - basic models: user, chat and messages
  - rspec
  - a style with bootstrap
  - the service that interfaces the LLM models using ollama
- Part 2
  - Added a UI
  - Prompt handled asynchronously in background
  - Propagating updates from server to clients
- Part 3
  - Deleting chats
  - AI answer returned by streaming
  - Error notification