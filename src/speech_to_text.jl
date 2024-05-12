"Calls the OpenAI Whisper API to transcribe audio"
function openai_whisper(file)
    url = "https://api.openai.com/v1/audio/transcriptions"
    headers = ["Authorization" => "Bearer $(PT.OPENAI_API_KEY)"]
    form = HTTP.Forms.Form(Dict(
        "file" => open(file), "model" => "whisper-1"))
    response = HTTP.post(url, headers, form)
    transcription = JSON3.read(response.body)["text"]
    return transcription
end