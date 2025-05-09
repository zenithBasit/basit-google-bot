import sys
import whisper
import warnings

warnings.filterwarnings("ignore", message=".*FP16 is not supported on CPU.*")
warnings.filterwarnings("ignore", category=UserWarning)

def transcribe_audio(file_path):
    try:
        model = whisper.load_model("base")
        result = model.transcribe(file_path, fp16=False)  # Explicitly disable FP16
        return result["text"]
    except Exception as e:
        print(f"CRITICAL_ERROR: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python transcribe.py <audio_file>")
        sys.exit(1)
    
    print(transcribe_audio(sys.argv[1]))