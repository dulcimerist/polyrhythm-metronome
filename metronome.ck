[4, 7, 13] @=> int beatsPerMeasure[];
50 => float baseBeatsPerMinute;
110 => float baseHz;
1.5 => float hzMultiplier;

60000 / baseBeatsPerMinute => float baseBeatMs;
(baseBeatMs * beatsPerMeasure[0]) => float measureMs;

Metronome metronomes[beatsPerMeasure.cap()];

for (0 => int i; i < metronomes.cap(); i++) {
    beatsPerMeasure[i] => metronomes[i].beatsPerMeasure;
    measureMs => metronomes[i].measureMs;
    baseHz * Math.pow(hzMultiplier, i) => metronomes[i].toneHz;
    spork ~ metronomes[i].play();
}

while (true)
    1::second => now;

public class Metronome {
    SinOsc osc;
    string name;
    float measureMs;
    int beatsPerMeasure;
    float toneHz;

    fun void play() {
        measureMs / beatsPerMeasure => float beatMs;
        50 => float toneMs;
        beatMs - toneMs => float silenceMs;

        0 => int currentBeat;

        osc => dac;
        0.0 => osc.gain;
        toneHz => osc.freq;
        while( true )
        {
            if (currentBeat > 0) {
                0.2 => osc.gain;
            } else {
                1.0 => osc.gain;
            }

            currentBeat++;
            <<< currentBeat >>>;
            if (currentBeat >= beatsPerMeasure)
                0 => currentBeat;
            toneMs::ms => now;
            0.0 => osc.gain;
            silenceMs::ms => now;
        }
    }
}