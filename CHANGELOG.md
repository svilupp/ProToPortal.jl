# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

Chat tab
- Added support for Groq's speech-to-text model for much lower latency

Prompt Builder tab
- Added a "Detailed view" button to toggle between a compact view and a detailed view
- Added an alternative template `:PromptGeneratorUpsampler` that generates a prompt template for chat without extensive examples (zero-shot prompt)

Configuration
- Changed default OpenAI model to GPT-4 Omni
- Improve grid layout and wider prompt textboxes

### Fixed
- Fixed a piracy warning in Aqua
- Improved subtle bugs in the Speech-to-text functionality on chat tab

## [0.2.0]

### Added

Chat tab
- Added delete icon to the last message in the conversation (for easy deletion)
- Added a button in "Advanced Settings" to "Fork a conversation" (save to history for reference, but continue from a fresh copy)
- Added a focus when a template is selected (on expand, on template selection, etc)
- Added a little edit icon for messages (disables the q-popup-edit that was distracting and jumping out too often)
- Added speech-to-text for the chat (click Record/Stop -> it will paste the text into the chat input and copy it in your clipboard)

Meta-prompting tab
- Added an experimental meta-prompting experience based on [arxiv](https://arxiv.org/pdf/2401.12954). See the tab "Meta-Prompting" for more details.

Prompt Builder tab
- Added a tab to generate "prompt templates" that you can then "Apply In Chat" (it jumps to the chat tab and provides template variables to fill in)
- Allows selecting different models (eg, Opus or more powerful ones) and defining how many samples are provided to give you a choice

## [0.1.0]

### Added
- The first iteration of the GUI released