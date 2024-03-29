# Wireless-Radio-using-Matlab

•	Developed a basic wireless receiver to decode a transmitted text message, with a center frequency of 20Hz and an incoming signal of 3000 samples at 100Hz sampling rate.
•	Downconverted both I and Q signals to baseband by multiplying the input with 3000-sample long cos and sin functions of frequency 20 Hz.
•	Filtered the downconverted signals using a 3000-point FFT, eliminating frequencies outside the range of -5.1 Hz to +5.1 Hz.
•	Downsampled the filtered output to a sample rate of 10Hz, retaining every 10th sample.
•	Correlated the signal with a known preamble to identify the start and end of transmitted symbols.
•	Demodulated each symbol using 16QAM constellation and symbol-to-bit mapping.
•	Converted demodulated symbols into characters based on ASCII codes.
•	Successfully decoded the transmitted text message, accounting for noise and potential errors.
•	Implemented a robust receiver capable of accurately processing wireless transmissions and converting them into readable text.

