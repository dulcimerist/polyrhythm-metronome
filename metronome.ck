// =====DIALS AND KNOBS, PLAY WITH THESE=====
[13, 7, 4] @=> int beatsPerMeasure[]; // Add, remove, or adjust polyrhythms
120 => float baseBeatsPerMinute; // Adjust tempo
440 => float baseHz; // Adjust base pitch for metronomes
1.5 => float hzMultiplier; // Adjust pitch offset for polyrhythms
// =====END OF DIALS AND KNOBS=====

60000 / baseBeatsPerMinute => float baseBeatMs; // 60000 milliseconds per minute
(baseBeatMs * beatsPerMeasure[0]) => float measureMs; // Use the first rhythm's time to determine how long all rhythms' measures should take

Metronome metronomes[beatsPerMeasure.cap()];

for (0 => int i; i < metronomes.cap(); i++) {
    // Sure wish ChucK had object constructors so I could just "new Metronome(beatsPerMeasure, measureMs, toneHz).play()"
    beatsPerMeasure[i] => metronomes[i].beatsPerMeasure;
    measureMs => metronomes[i].measureMs;
    baseHz * Math.pow(hzMultiplier, i) => metronomes[i].toneHz; // Each subsequent rhythm will have a higher pitch based on the base pitch and how many rhythms have come before it, multiplicative so we don't have octaves
    spork ~ metronomes[i].play(i); // Only passing the index in to have the nice printout of which rhythm index is at which beat
}

while (true) // Play forever, until you kill the script
    1::second => now;

public class Metronome {
    SinOsc osc;
    string name;
    float measureMs;
    int beatsPerMeasure;
    float toneHz;

    fun void play(int rhythmIndex) {
        measureMs / beatsPerMeasure => float beatMs;
        50 => float toneMs;
        beatMs - toneMs => float silenceMs; // NOTE: This will bug out if our BPM is fast enough to make this value negative - we may want to handle for that by computing appropriate tone durations based on the fastest rhythm, rather than hardcoding it to the above value

        0 => int currentBeat;

        osc => dac;
        0.0 => osc.gain;
        toneHz => osc.freq;
        while( true ) // Run forever until the parent thread (shred??? ChucK, you goofy) is killed
        {
            if (currentBeat == 0) {
                1.0 => osc.gain; // fortissimo (be very loud) on the first beat of the measure
            } else {
                0.2 => osc.gain; // mezzo piano (be moderately quiet) on the subsequent beats
            }

            currentBeat++;
            <<< "Rhythm " + rhythmIndex + " - Beat " + currentBeat >>>;
            if (currentBeat >= beatsPerMeasure) // reset counter for the next beat if we've reached the end of the measure
                0 => currentBeat;
            toneMs::ms => now;
            0.0 => osc.gain;
            silenceMs::ms => now; // See note on the silenceMs declaration
        }
    }
}