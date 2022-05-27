import time
import wave
import sys

try:
    import azure.cognitiveservices.speech as speechsdk
except ImportError:
    print("""
    Importing the Speech SDK for Python failed.
    Refer to
    https://docs.microsoft.com/azure/cognitive-services/speech-service/quickstart-python for
    installation instructions.
    """)
    sys.exit(1)


def detect_language(file_path, speech_key, service_region):
    """
        This function will perform speech recognition from a give input file

        parameters:
            file_path (string): This is the path to the wav file 
            speech_key (string): This is the API key used to connect to azure services
            service_region (string): This is the default service region used to connect to a specific azure region    
    """
    speech_config = speechsdk.SpeechConfig(subscription=speech_key, region=service_region)
    auto_detect_source_language_config = speechsdk.languageconfig.AutoDetectSourceLanguageConfig(languages=["en-US", "es-ES"])
    try:
            
        audio_config = speechsdk.audio.AudioConfig(filename=file_path)

        speech_recognizer = speechsdk.SpeechRecognizer(
            speech_config=speech_config, 
            auto_detect_source_language_config=auto_detect_source_language_config, 
            audio_config=audio_config)
            

        result = speech_recognizer.recognize_once()

        auto_detect_source_language_result = speechsdk.AutoDetectSourceLanguageResult(result)
        detected_language = auto_detect_source_language_result.language

        return "en-US" if detected_language is None else detected_language
    except Exception as inst:
        return str(inst)

if __name__ == "__main__":
    """
        This python file performs language detection from the arguments provided

        This python file should be called in the format 
            `python3 process.py file_path azure_api_key azure_service_region`
        
        arguments:
            arg0 (string): The file path of the wav file which is to be processed to detect the language
            arg1 (string): The Microsoft Azure API key used for speech cognitive services
            arg2 (string): the region for the Microsoft Azure service
        
        returns:
            language (string): The detected language of the file. (Defaults to en-US if one wasn't detected)
    """
    args = [arg for arg in sys.argv[1:]]
    path = args[0] 
    api_key = args[1] 
    region = args[2]

    language = detect_language(path, api_key, region)
z
    print(language)