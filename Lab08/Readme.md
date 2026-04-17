Here is a structured breakdown to help you tackle the design, analysis, and expected outcomes for these lab tasks. 

### **Task 1: Filter Design & Error Propagation**

[cite_start]You need to select components that satisfy the given constraints: a gain ($G$) between 2 and 10 [cite: 150][cite_start], a cutoff frequency ($f_c$) between 50 Hz and 100 Hz [cite: 151][cite_start], and an input resistor ($R_1$) $\ge 1\text{ k}\Omega$[cite: 152].

**1. Selecting the Components:**
Let's design for a target gain of roughly 4.7 and a cutoff frequency around 72 Hz, which uses easily available standard component values.
* **$R_1$ (Input Resistor):** $1\text{ k}\Omega$ (satisfies the $\ge 1\text{ k}\Omega$ rule).
* **$R_2$ (Feedback Resistor):** $4.7\text{ k}\Omega$. 
    * *Theoretical Gain:* $G = \frac{R_2}{R_1} = 4.7$
* **$C_2$ (Feedback Capacitor):** $0.47\mu\text{F}$.
    * *Theoretical Cutoff:* $f_c = \frac{1}{2\pi R_2 C_2} = \frac{1}{2\pi (4700)(0.47 \times 10^{-6})} \approx 72.05\text{ Hz}$.

**2. Calculating Uncertainty (Error Propagation):**
When you measure these components with the Rigol DM3058 multimeter in the lab, you will get exact values and an associated uncertainty ($U_{R1}, U_{R2}, U_{C2}$) based on the device's manual. To find the uncertainty of your calculated parameters, use the standard error propagation formula using partial derivatives.

* **Gain Uncertainty ($U_G$):**
    $$U_G = G \sqrt{\left(\frac{U_{R1}}{R_1}\right)^2 + \left(\frac{U_{R2}}{R_2}\right)^2}$$

* **Cutoff Frequency Uncertainty ($U_{f_c}$):**
    $$U_{f_c} = f_c \sqrt{\left(\frac{U_{R2}}{R_2}\right)^2 + \left(\frac{U_{C2}}{C_2}\right)^2}$$

---

### **Task 3: Expected Time-Domain Waveforms**

When you plot the three specific datasets, here is exactly what the filter should be doing to your input signal:

1.  **At $f_c / 10$ (e.g., ~7.2 Hz):** You are deep in the passband. The output wave should be amplified by your gain factor (e.g., 4.7x larger) and perfectly inverted (a $180^\circ$ phase shift) compared to the input because of the inverting op-amp configuration. There should be no noticeable attenuation.
2.  **At $f_c$ (e.g., ~72 Hz):** You are at the cutoff point. The output amplitude should be $-3\text{ dB}$ down from the passband gain, meaning the output voltage amplitude will be $G \times \frac{1}{\sqrt{2}} \approx 0.707 \times G$. The phase will lag an additional $45^\circ$, looking like a $-225^\circ$ (or $+135^\circ$) total shift.
3.  **At $10 \times f_c$ (e.g., ~720 Hz):** You are in the stopband. The signal will be heavily attenuated (it should be $-20\text{ dB}$ smaller than the signal at cutoff). The phase shift will approach $-270^\circ$ (or $+90^\circ$).

---

### **Task 4: Bode Diagram Reporting**

When analyzing your generated Bode plots, here are the theoretical values you should be verifying against your experimental data:

* **Passband Magnitude:** Should flatten out at $20 \log_{10}(G)$. For a gain of 4.7, this is roughly $13.4\text{ dB}$.
* **Passband Phase:** Should be $-180^\circ$ (or $180^\circ$) due to the standard inverting amplifier behavior.
* **-3dB Frequency:** Locate the frequency where the magnitude drops to $13.4\text{ dB} - 3\text{ dB} = 10.4\text{ dB}$. This experimental frequency should fall within the bounds of your $f_c \pm U_{f_c}$ calculation from Task 1.
* [cite_start]**Phase at $f_c$:** Should be approximately $-225^\circ$[cite: 76, 78].
* [cite_start]**High-Frequency Slope:** The magnitude plot should decrease at a constant rate of $-20\text{ dB/decade}$[cite: 69].
* [cite_start]**High-Frequency Phase Limit:** The phase should flatten out and asymptotically approach $-270^\circ$[cite: 77, 78].

---

### **Task 5: The Sawtooth Wave Hypothesis**

To hypothesize what happens to a sawtooth wave with a fundamental frequency of $0.5 \times f_c$, you need to think about it in the frequency domain. 

A sawtooth wave is not a single frequency; it is composed of a fundamental frequency and an infinite sum of integer harmonics (2nd, 3rd, 4th, etc.), with amplitudes decreasing as the frequency increases. Since you are well-versed in linear circuit theory, analyzing how a network transfers these individual harmonic components makes predicting the output straightforward.

* **The Fundamental ($0.5 f_c$):** This frequency is in the passband. It will pass through with the full gain of the amplifier.
* **The 2nd Harmonic ($1.0 f_c$):** This lands exactly on the cutoff frequency. It will be attenuated by $3\text{ dB}$.
* **The 3rd Harmonic ($1.5 f_c$) and beyond:** These frequencies sit in the stopband and will be aggressively attenuated by the $-20\text{ dB/decade}$ roll-off.

**Conclusion:** The sharp, abrupt edges of a sawtooth wave are created by the presence of those high-frequency harmonics. Because your low-pass filter strips those high frequencies away while letting the fundamental pass, the output wave will look "smoothed out." The sharp peaks will round off, and the resulting waveform will look significantly closer to a slightly distorted sine wave than a sawtooth.