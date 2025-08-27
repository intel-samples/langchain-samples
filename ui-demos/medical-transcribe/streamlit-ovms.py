import streamlit as st
import requests
import tempfile
import os
from io import BytesIO
import numpy as np
import librosa
import soundfile as sf
import re
import json
from datetime import date

# Whisper API URL
WHISPER_API_URL = "http://127.0.0.1:5910/inference"
LLM_API_URL = "http://localhost:8013/v3/chat/completions"

st.set_page_config(page_title="Medical Transcribe", layout="wide", initial_sidebar_state="auto")

# Initialize session state
if 'transcription' not in st.session_state:
    st.session_state.transcription = ""
if 'summary' not in st.session_state:
    st.session_state.summary = ""
if 'json_data' not in st.session_state:
    st.session_state.json_data = {}
if 'confirmed_data' not in st.session_state:
    st.session_state.confirmed_data = {}
if 'show_editor' not in st.session_state:
    st.session_state.show_editor = False

def transcribe_audio(audio_path):
    """Send recorded audio to Whisper API and return the transcription."""
    with open(audio_path, "rb") as f:
        files = {"file": f}
        data = {"response-format": "json"}
        proxies = {"http": None, "https": None}
        response = requests.post(WHISPER_API_URL, files=files, data=data, proxies=proxies)
        
    if response.status_code == 200:
        return response.json().get("text", "No transcription received.")
    else:
        return f"Error: {response.status_code} - {response.text}"

def summarizer(transcription):

    system_prompt = """You are an AI medical assistant tasked with generating structured Emergency Department (ED) reports based strictly on the provided recorded convertsation between patient and doctor input. Do not add any information that is not explicitly stated in the input. If a field is missing or not provided, exclude it from the report.

    ### Instructions:
    - Use a **point-based format** for clarity.
    - Report only the information present in the input **without assumptions or additional details**.
    - If a section has **no relevant data in the input**, do not include it in the output.
    - Use neutral and professional language suitable for a clinical report.

    ### Report Format:

    **Emergency Department Report**
    - **Patient**: [age]-year-old [sex]
    - **Chief Complaint**: [chief complaint]
    - **History of Present Illness**:
    - [Details about the symptom and any provided characteristics]
    - **Associated Symptoms**: [List any additional symptoms]
    - **Past Medical History**: [List past medical conditions or state 'No past medical history' if specified]
    - **Medications & Allergies**: [List active medications and allergies or state 'None' if specified]
    - **Surgical History**: [List past surgical procedures or state 'None' if specified]
    - **Family History**: [List family history or state 'None' if specified]
    - **Social History**: [Smoking status, alcohol consumption as provided]

    **Strict Rule**: Do not infer, assume, or generate any information that is not explicitly stated in the input. If a field is missing, do not fabricate or fill in the blanks. The output should be a **direct representation of the provided data** only."""

    data = {
            "model": "meta-llama/Llama-3.2-3B-Instruct",
            "max_tokens": 256,
            "temperature": 0,
            "top_p": 1,
            "top_k": 50,
            "repetition_penalty": 1.2,
            "stream": False,
            "messages": [
                {
                    "role": "system",
                    "content": system_prompt
                },
                {
                    "role": "user",
                    "content": transcription 
                }
            ]
        }

    output_box = st.empty()

    response = requests.post(LLM_API_URL, json=data, headers={"Content-Type": "application/json"})
    if response.status_code == 200:
        output_json = response.json()
        output_text = output_json["choices"][0]["message"]["content"]
        output_box.write(output_text)
    
    return output_text

def jsonizer(summary):

    system_prompt = '''
    You are a data extraction assistant. Your task is to convert an emergency department report into a structured JSON format using only the information explicitly provided in the report. Follow these instructions precisely:

    Format the output as:
    {
        "age": "",
        "sex": "",
        "chief_complaint": "",
        "symptom_description": "",
        "symptom_duration": "",
        "associated_symptoms": [],
        "past_medical_history": "",
        "current_medications": "",
        "medication_allergies": "",
        "surgical_history": "",
        "family_history": "",
        "smoking_status": "",
        "alcohol_consumption": ""
    }

    Rules:
    - Extract values exactly as stated in the report.
    - Convert to lowercase where applicable (e.g., "Female" → "female").
    - For associated_symptoms, include only explicitly listed symptoms in lowercase, as an array of strings.
    - If a section says “None,” map it to "No" in the relevant field.
    - If any field is not mentioned in the report, leave its value as an empty string.
    - Do not infer, summarize, or add new information.
    - Do not modify phrasing except where the example clearly demonstrates a transformation (e.g., "Does not smoke" → "No").

    Your output must be a valid JSON object following this exact field structure and naming convention.
    '''

    data = {
        "model": "meta-llama/Llama-3.2-3B-Instruct",
        "max_tokens": 256,
        "temperature": 0.1,
        "top_p": 1,
        "top_k": 50,
        "repetition_penalty": 1.2,
        "stream": False,
        "messages": [
            {
                "role": "system",
                "content": system_prompt
            },
            {
                "role": "user",
                "content": summary 
            }
        ]
    }

    response = requests.post(LLM_API_URL, json=data, headers={"Content-Type": "application/json"})
    if response.status_code == 200:
        output_json = response.json()
        output_text = output_json["choices"][0]["message"]["content"]
    
    return output_text

def preprocess_audio(audio_path):
    """Preprocess recorded audio to 16kHz."""
    y, sr = librosa.load(audio_path, sr=16000)
    sf.write(audio_path, y, 16000)
    return audio_path

def handle_audio_submission(temp_audio_path):
    temp_audio_path = preprocess_audio(temp_audio_path)
    st.session_state.transcription = transcribe_audio(temp_audio_path)
    
    # Create two columns for side-by-side display
    col1, col2 = st.columns(2)
        
    with col1:
        st.subheader("Transcription:")
        with st.container(border=True):
            st.write(st.session_state.transcription)
        
    with col2:
        st.subheader("Summary:")
        with st.container(border=True):
            st.session_state.summary = summarizer(st.session_state.transcription)


    
    json_dict = jsonizer(st.session_state.summary)

    # Parse and store JSON data in session state
    json_text = re.search(r"\{.*\}", json_dict, re.DOTALL)
    if json_text:
        json_str = json_text.group(0)
        st.session_state.json_data = json.loads(json_str)
        st.session_state.show_editor = True

    os.remove(temp_audio_path)

# for display the json and can be edit by user
def display_json_editor():
    if not st.session_state.json_data:
        return None
        
    data = st.session_state.json_data
    
    st.subheader("Edit Medical Information:")
    
    chief_complaint = st.text_input("Chief Complaint", value=data.get('chief_complaint', ''), key='chief_complaint')
    symptom_description = st.text_input("Symptom Description", value=data.get('symptom_description', ''), key='symptom_description')
    symptom_duration = st.text_input("Symptom Duration", value=data.get('symptom_duration', ''), key='symptom_duration')
    associated_symptoms = st.text_input("Associated Symptoms", value=str(data.get('associated_symptoms', '')), key='associated_symptoms')
    past_medical_history = st.text_input("Past Medical History", value=data.get('past_medical_history', ''), key='past_medical_history')
    current_medications = st.text_input("Current Medications", value=data.get('current_medications', ''), key='current_medications')
    medication_allergies = st.text_input("Medication Allergies", value=data.get('medication_allergies', ''), key='medication_allergies')
    surgical_history = st.text_input("Surgical History", value=data.get('surgical_history', ''), key='surgical_history')
    family_history = st.text_input("Family History", value=data.get('family_history', ''), key='family_history')
    smoking_status = st.text_input("Smoking Status", value=data.get('smoking_status', ''), key='smoking_status')
    alcohol_consumption = st.text_input("Alcohol Consumption", value=data.get('alcohol_consumption', ''), key='alcohol_consumption')

    if st.button('Confirm Data', key='confirm_button'):
        st.session_state.confirmed_data = {
            'chief_complaint': chief_complaint,
            'symptom_description': symptom_description,
            'symptom_duration': symptom_duration,
            'associated_symptoms': associated_symptoms,
            'past_medical_history': past_medical_history,
            'current_medications': current_medications,
            'medication_allergies': medication_allergies,
            'surgical_history': surgical_history,
            'family_history': family_history,
            'smoking_status': smoking_status,
            'alcohol_consumption': alcohol_consumption
        }
        st.success("Data confirmed! You can now send to EMR.")
        st.json(st.session_state.confirmed_data)
        # st.rerun()

# Streamlit UI
st.title("Medical Transcribe")
st.write("Upload or record audio, and transcribe and summarize it using Whisper.cpp API and Llama3.2 3B")
    

# Upload audio feature
uploaded_file = st.sidebar.file_uploader("Upload a WAV audio file", type=["wav"])

# Audio recording feature
audio_data = st.sidebar.audio_input("Record Audio")

if audio_data is not None:
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
        temp_audio.write(audio_data.getvalue())
        temp_audio_path = temp_audio.name

    st.sidebar.success(f"Audio recorded and saved to {temp_audio_path}")

    if st.sidebar.button("Submit Query", key='submit_recorded'):
        handle_audio_submission(temp_audio_path)

if uploaded_file is not None:
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as temp_audio:
        temp_audio.write(uploaded_file.getvalue())
        temp_audio_path = temp_audio.name
    
    if st.sidebar.button("Submit Query", key='submit_uploaded'):
        handle_audio_submission(temp_audio_path)

# Show JSON editor if data is available
if st.session_state.show_editor and st.session_state.json_data:
    display_json_editor()

    




