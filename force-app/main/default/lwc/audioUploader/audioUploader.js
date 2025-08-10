import { LightningElement, wire, track, api } from 'lwc';
import transcribeAudio from '@salesforce/apex/OpenAITranscriptionHandler.transcribeAudio';

export default class AudioTranscriber extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track transcription = '';
    @track error = '';
    @track isProcessing = false;

    handleFileUpload(event) {
        this.isProcessing = true;
        this.error = '';
        this.transcription = '';

        const file = event.target.files[0];
        if (!file) return;

        // Validate file type
        const validTypes = ['audio/mpeg', 'audio/wav', 'audio/webm', 'audio/mp3'];
        if (!validTypes.includes(file.type)) {
            this.error = 'Unsupported file type. Please upload MP3, WAV, or WEBM.';
            this.isProcessing = false;
            return;
        }

        // Validate file size (25MB max for OpenAI Whisper)
        const maxSize = 25 * 1024 * 1024; // 25MB
        if (file.size > maxSize) {
            this.error = 'File too large. Maximum size is 25MB.';
            this.isProcessing = false;
            return;
        }

        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            this.sendToApex(base64, file.name, file.type);
        };
        reader.readAsDataURL(file);
    }

    sendToApex(fileContent, fileName, mimeType) {
        transcribeAudio({
            fileContent: fileContent,
            fileName: fileName,
            mimeType: mimeType,
            objectApiName: this.objectApiName,
            recordId: this.recordId
        })
        .then(result => {
            if (result.error) {
                this.error = result.error;
            } else {
                this.transcription = result.transcription;
            }
            this.isProcessing = false;
        })
        .catch(error => {
            this.error = error.body?.message || error.message || 'Unknown error';
            this.isProcessing = false;
        });
    }

    get hasError() {
        return this.error !== '';
    }

    get showSpinner() {
        return this.isProcessing;
    }
}