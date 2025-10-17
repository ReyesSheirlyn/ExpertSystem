import pandas as pd
import json
from datetime import datetime

def save_result_to_csv(clips_data, decision):
    file_path = "adoption_results.csv"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    row = {
        "timestamp": timestamp,
        "adopter_data": json.dumps(clips_data, indent=2),
        "decision": json.dumps(decision, indent=2)
    }

    try:
        df = pd.read_csv(file_path)
        df = pd.concat([df, pd.DataFrame([row])], ignore_index=True)
    except (FileNotFoundError, pd.errors.EmptyDataError):
        df = pd.DataFrame([row])

    df.to_csv(file_path, index=False)
    print(f"✅ Saved result to {file_path}")
