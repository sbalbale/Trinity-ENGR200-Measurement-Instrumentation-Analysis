[cite_start]Here is a complete set of standard component values selected to perfectly meet all the design constraints outlined in Task 1 of your lab manual[cite: 148, 149, 150, 151, 152]. 

### **1. Component Selection**
To ensure we use easily available, standard off-the-shelf components (E12/E24 series), here are the chosen values:

* **Input Resistor ($R_1$):** $10\text{ k}\Omega$
    * [cite_start]*Constraint Check:* This easily satisfies the requirement that $R_1 \ge 1\text{ k}\Omega$[cite: 152].
* **Feedback Resistor ($R_2$):** $51\text{ k}\Omega$
* **Feedback Capacitor ($C_2$):** $47\text{ nF}$ (which is equivalent to $0.047\mu\text{F}$)

### **2. Theoretical Operating Points**
[cite_start]Based on the components selected above, here are your designed operating points to report for Task 1e[cite: 155]:

* **Theoretical Gain Magnitude ($|G|$):**
    $$|G| = \frac{R_2}{R_1} = \frac{51,000}{10,000} = 5.1$$
    * [cite_start]*Constraint Check:* $5.1$ is comfortably between 2 and 10[cite: 150]. [cite_start]Note that because it is an inverting amplifier, the actual applied gain is $-5.1$[cite: 62].
* **Theoretical Cutoff Frequency ($f_c$):**
    $$f_c = \frac{1}{2\pi R_2 C_2} = \frac{1}{2\pi (51,000)(47 \times 10^{-9})} \approx 66.43\text{ Hz}$$
    * [cite_start]*Constraint Check:* $66.43\text{ Hz}$ is comfortably between $50\text{ Hz}$ and $100\text{ Hz}$[cite: 151, 63].

*(Note: In your MATLAB scripts, you will want to update the `fc = 75;` line to `fc = 66.4;` to match this exact design).*

---

### **3. Uncertainty & Error Propagation Framework**
[cite_start]The lab manual asks you to calculate the uncertainty of your gain and cutoff frequency based on the actual measurements you take with the Rigol DM3058 Benchtop Multimeter[cite: 153, 156]. 

Because you haven't taken the physical measurements yet, here is the exact framework and math you will use once you are at the bench. 

**Step A: Record Your Measurements**
[cite_start]When you use the Rigol multimeter, write down the exact measured value and the device's stated uncertainty (found in the manual's accuracy specifications)[cite: 133, 134]. Let's say, hypothetically, you measure:
* $R_1 = 9.98\text{ k}\Omega \pm 0.01\text{ k}\Omega$ (where $0.01$ is $U_{R1}$)
* $R_2 = 51.12\text{ k}\Omega \pm 0.05\text{ k}\Omega$ (where $0.05$ is $U_{R2}$)
* $C_2 = 46.5\text{ nF} \pm 0.4\text{ nF}$ (where $0.4$ is $U_{C2}$)

**Step B: Calculate Parameter Uncertainty**
You will use the standard root-sum-square method for error propagation based on partial derivatives. 

**For Gain Uncertainty ($U_G$):**
$$U_G = G \sqrt{\left(\frac{U_{R1}}{R_1}\right)^2 + \left(\frac{U_{R2}}{R_2}\right)^2}$$
*(Using the hypothetical numbers above: $U_G \approx 5.12 \times \sqrt{(0.01/9.98)^2 + (0.05/51.12)^2} \approx \pm 0.007$)*

**For Cutoff Frequency Uncertainty ($U_{f_c}$):**
$$U_{f_c} = f_c \sqrt{\left(\frac{U_{R2}}{R_2}\right)^2 + \left(\frac{U_{C2}}{C_2}\right)^2}$$
*(Using the hypothetical numbers above: $U_{f_c} \approx 67.0 \times \sqrt{(0.05/51.12)^2 + (0.4/46.5)^2} \approx \pm 0.58\text{ Hz}$)*