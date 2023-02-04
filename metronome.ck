// =====DIALS AND KNOBS, PLAY WITH THESE=====
[13, 7, 4] @=> int beatsPerMeasure[]; // Add, remove, or adjust polyrhythms
120 => float baseBeatsPerMinute; // Adjust tempo
440 => float baseHz; // Adjust base pitch for metronomes
1.5 => float hzMultiplier; // Adjust pitch offset for polyrhythms
// =====END OF DIALS AND KNOBS=====

(beatsPerMeasure[0] / baseBeatsPerMinute)::minute => dur measure; // Use the first rhythm's time to determine how long all rhythms' measures should take

Metronome metronomes[beatsPerMeasure.cap()]; // Sure wish ChucK had object constructors so I could just define "[Metronome(beatsPerMeasure, toneHz),...]" instead of maintaining a separate array of beats per measure integers and metronome objects, then looping to assign one to the other

for (0 => int i; i < metronomes.cap(); i++) {
    beatsPerMeasure[i] => metronomes[i].beatsPerMeasure;
    baseHz * Math.pow(hzMultiplier, i) => metronomes[i].toneHz; // Each subsequent rhythm will have a higher pitch based on the base pitch and how many rhythms have come before it, multiplicative so we don't have octaves
    spork ~ metronomes[i].play();
}

while (true) // Play forever, until you kill the script
    1::second => now;

public class Metronome {
    TriOsc osc;
    int beatsPerMeasure;
    float toneHz;

    fun void play() {
        50::ms => dur tone;
        (1.0/beatsPerMeasure)::measure => dur beat;

        osc => dac;
        0.0 => osc.gain;
        toneHz => osc.freq;
        0 => int currentBeat;
        while( true ) // Run forever until the parent thread (shred??? ChucK, you goofy) is killed
        {
            currentBeat == 0 ? 1.0 : 0.2 => osc.gain; // fortissimo (very loud) on the first beat of the measure, mezzo piano (moderately quiet) on subsequent beats

            currentBeat++;
            <<< beatsPerMeasure + " - " + currentBeat >>>;
            if (currentBeat >= beatsPerMeasure) // reset counter for the next beat if we've reached the end of the measure
                0 => currentBeat;
            1::tone => now;
            0.0 => osc.gain;
            1::beat - 1::tone => now; //NOTE: If you reach a sufficiently high BPM, this may become negative and cause things to crash - we may want to compute the tone duration based on a percentage of the highest BPM rhythm in the future
        }
    }
}