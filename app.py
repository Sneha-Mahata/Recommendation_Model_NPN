import os
import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any
from recommender import ensemble_recommend, generate_explanations

app = FastAPI(title="Hotel Finder NextStay")

class PrefsModel(BaseModel):
    user_id: Optional[int] = None
    user_preferences: Dict[str, Any]
    top_n: Optional[int] = 5
    explain: Optional[bool] = False
    llm_model: Optional[str] = "gemini-1.5-flash"

@app.get("/healthz")
def health():
    return {"status": "ok"}

@app.post("/recommend")
def recommend(payload: PrefsModel):
    try:
        recs = ensemble_recommend(payload.user_preferences, user_id=payload.user_id, top_n=payload.top_n)
        # if user asked for LLM explanations, try to generate them (may return llm_error fields)
        if payload.explain:
            recs = generate_explanations(recs, payload.user_preferences, model_name=payload.llm_model)
        return {"status": "success", "results": recs}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("app:app", host="0.0.0.0", port=port, reload=False)
