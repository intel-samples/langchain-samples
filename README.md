# LangChain* - Intel® GenAI Reference Samples

Various Intel® hardware and LangChain based examples are provided. Different parts of the workload can be distributed across edge, on-prem, or a CSP devices/infrastructure.

| Demo  | Description |
| ------------- | ------------- |
| [Video-Summarization](video-summarization)  | Summarize Videos Using OpenVINO Model Server, Langchain, and MiniCPM-V-2_6. The primary components are OVMS (OpenVINO Model Server), OpenVINO for Intel optimized models, LangChain, MiniCPM v2.6, Llama 3.2, BLIP, Milvus and D-FINE for object detection. Query search/retrieval with multimodal RAG. |
| [Vision-RAG](vision-rag)  | Vision RAG with FastSAM, CLIP, FAISS and MiniCPM. Identify food items from a food tray using open-source zero shot object detection models and embedding models without finetuning and FAISS as the vector database. |
| [UI Demo - Medical Transcribe](ui-demos/medical-transcribe)  | Ubuntu & Windows 11 Streamlit UI demo which uses Whipser.cpp + OpenVINO™ backend for ASR and LLama3.2-3B via OpenVINO™ Model Server (OVMS) for improving operational efficiency of healthcare documentation for direct patient care. |
| [UI Demo - Video-Summarization](ui-demos/video-summarization)  | Summarize Videos Using OpenVINO-GenAI, Langchain, and MiniCPM-V-2_6 with a Streamlit UI. Recaptions anomalous video chunks with Google Gemini. |
| <b>Public archive</b> - [Chapterization](chapterization) | <b>This sample was archived by the owner on August 14th, 2025. It is now read-only.</b> Demonstrates an pipeline which automatically chapterizes long text/content from a provided audio context. The primary components utilize OpenVINO™ in LangChain* for audio-speech-recognition, embeddings generation, K-means clustering, and LLM chapterization.  |
| <b>Public archive</b> - [QnA](qna)  | <b>This sample was archived by the owner on August 14th, 2025. It is now read-only.</b> Demonstrates a pipeline which performs QnA using audio or text with RAG. The primary components utilize OpenVINO™ in LangChain for audio-speech-recognition, LLM text generation/response, and text-to-speech.   |
| <b> Public archive</b> - [Eval-Text-Summarization-Benchmarking](genai-eval-text-summarization-benchmarking)  | <b>This sample was archived by the owner on August 14th, 2025. It is now read-only.</b> Perform a qualitative assessment of a candidate summarization by comparing it to a reference response. Metrics calculated are BLEU, ROUGE-N, and BERTScore  |

<b>Note:</b> Please refer to following [guide](https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-linux/2023-0/gpu-disable-hangcheck.html) for disabling GPU hangchecks.

<b>FFmpeg</b>

FFmpeg is an open source project licensed under LGPL and GPL. See https://www.ffmpeg.org/legal.html. You are solely responsible for determining if your use of FFmpeg requires any additional licenses. Intel is not responsible for obtaining any such licenses, nor liable for any licensing fees due, in connection with your use of FFmpeg.

<b>AI Model Usage</b>

This repository utilizes various AI models, including fully open-source models (e.g., Apache 2.0, MIT-licensed models) and openly available models (e.g., Meta’s LLaMA). Each model remains the intellectual property of its respective creators and is governed by its original license. Fully open-source models such as Qwen, Mistral, and Phi allow unrestricted use, modification, and distribution under their respective licenses. Models like LLaMA are available under specific usage terms that may include restrictions. This document does not redistribute, modify, or alter any model weights, nor does it claim ownership over them. Users should consult the official licensing terms of each model before use. The inclusion of specific models in this whitepaper does not imply endorsement by their respective developers. The recommendations presented are based on independent research and do not constitute official guidance from Meta, OpenAI, Google, or any other model provider. 





