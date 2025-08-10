public with sharing class OpenAITranscriptionHandler {
    @AuraEnabled(cacheable=false)
    public static TranscriptionResult transcribeAudio(String fileContent, String fileName, String mimeType, String objectApiName, String recordId) {
        TranscriptionRequest req = new TranscriptionRequest();
        req.fileContent = fileContent;
        req.fileName = fileName;
        req.mimeType = mimeType;
        req.objectApiName = objectApiName;
        req.recordId = recordId;
        
        return processAudio(new List<TranscriptionRequest>{req})[0];
    }
    @InvocableMethod(label='Transcribe Audio' category='Inspection')
    public static List<TranscriptionOutput> processAudioFromFlow(List<TranscriptionFlowInput> requests) {
        List<TranscriptionRequest> internalRequests = new List<TranscriptionRequest>();
        for (TranscriptionFlowInput req : requests) {
            internalRequests.add(new TranscriptionRequest(
                req.fileContent,
                req.fileName,
                req.mimeType,
                req.objectApiName,
                req.recordId
            ));
        }
        
        List<TranscriptionResult> results = processAudio(internalRequests);
        List<TranscriptionOutput> outputs = new List<TranscriptionOutput>();
        for (TranscriptionResult res : results) {
            outputs.add(new TranscriptionOutput(res));
        }
        return outputs;
    }

    // Internal processing method
    private static List<TranscriptionResult> processAudio(List<TranscriptionRequest> requests) {
        List<TranscriptionResult> results = new List<TranscriptionResult>();
        OpenAI_Config__mdt config = OpenAI_Config__mdt.getInstance('Production');
        
        if (config == null || config.API_Key__c == null) {
            results.add(new TranscriptionResult('OpenAI configuration missing'));
            return results;
        }

        for (TranscriptionRequest req : requests) {
            try {
                HttpRequest httpReq = buildOpenAIRequest(config.API_Key__c, req);
                HttpResponse httpRes = new Http().send(httpReq);
                results.add(parseResponse(httpRes));
            } catch (Exception e) {
                results.add(new TranscriptionResult('Error: ' + e.getMessage() + ' (Line: ' + e.getLineNumber() + ')'));
            }
        }
        return results;
    }

    private static HttpRequest buildOpenAIRequest(String apiKey, TranscriptionRequest req) {
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint('https://api.openai.com/v1/audio/transcriptions');
        httpReq.setMethod('POST');
        httpReq.setHeader('Authorization', 'Bearer ' + apiKey);
        httpReq.setHeader('Content-Type', 'multipart/form-data; boundary=' + getBoundary());
        httpReq.setBodyAsBlob(createBody(req));
        httpReq.setTimeout(120000);
        return httpReq;
    }

    private static Blob createBody(TranscriptionRequest req) {
        String boundary = getBoundary();
        String body = '';
        body += '--' + boundary + '\r\n';
        body += 'Content-Disposition: form-data; name="file"; filename="' + req.fileName + '"\r\n';
        body += 'Content-Type: ' + req.mimeType + '\r\n\r\n';
        body += EncodingUtil.base64Decode(req.fileContent) + '\r\n';
        body += '--' + boundary + '\r\n';
        body += 'Content-Disposition: form-data; name="model"\r\n\r\n';
        body += 'whisper-1\r\n';
        body += '--' + boundary + '--';
        return Blob.valueOf(body);
    }

    private static TranscriptionResult parseResponse(HttpResponse res) {
        TranscriptionResult result = new TranscriptionResult();
        if (res.getStatusCode() != 200) {
            result.error = 'API Error ' + res.getStatusCode() + ': ' + res.getBody();
            return result;
        }
        
        try {
            Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            result.transcription = (String)response.get('text');
        } catch (Exception e) {
            result.error = 'Parse Error: ' + e.getMessage();
        }
        return result;
    }

    private static String getBoundary() {
        return '----WebKitFormBoundary7MA4YWxkTrZu0gW';
    }

    // Internal request class
    public class TranscriptionRequest {
        public String fileContent;
        public String fileName;
        public String mimeType;
        public String objectApiName;
        public String recordId;
        
        public TranscriptionRequest() {}
        public TranscriptionRequest(String fileContent, String fileName, String mimeType, String objectApiName, String recordId) {
            this.fileContent = fileContent;
            this.fileName = fileName;
            this.mimeType = mimeType;
            this.objectApiName = objectApiName;
            this.recordId = recordId;
        }
    }

    // Output class for LWC
    public class TranscriptionResult {
        @AuraEnabled public String transcription;
        @AuraEnabled public String error;
        
        public TranscriptionResult() {}
        public TranscriptionResult(String error) {
            this.error = error;
        }
    }

    // Input class for Flow
    public class TranscriptionFlowInput {
        @InvocableVariable(label='File Content (Base64)' required=true)
        public String fileContent;
        
        @InvocableVariable(label='File Name' required=true)
        public String fileName;
        
        @InvocableVariable(label='MIME Type' required=true)
        public String mimeType;
        
        @InvocableVariable(label='Object API Name' required=true)
        public String objectApiName;
        
        @InvocableVariable(label='Record ID' required=true)
        public String recordId;
    }

    // Output class for Flow
    public class TranscriptionOutput {
        @InvocableVariable(label='Transcription Text')
        public String transcription;
        
        @InvocableVariable(label='Error Message')
        public String error;
        
        public TranscriptionOutput(TranscriptionResult res) {
            this.transcription = res.transcription;
            this.error = res.error;
        }
    }
}