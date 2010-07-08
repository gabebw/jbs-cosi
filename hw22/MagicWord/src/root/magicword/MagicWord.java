package root.magicword;

import java.util.List;

import root.magicword.speech.SpeechGatheringActivity;
import root.magicword.speech.TextSpeakerAndroid;
import android.os.Bundle;
import android.speech.tts.TextToSpeech.OnUtteranceCompletedListener;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MagicWord extends SpeechGatheringActivity implements OnUtteranceCompletedListener
{
    private TextSpeakerAndroid speaker;
    
    private TextView result;
    
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) 
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        speaker = new TextSpeakerAndroid(this);
        
        Button speak = (Button)findViewById(R.id.bt_speak);
        speak.setOnClickListener(new View.OnClickListener()
        {
            @Override
            public void onClick(View v)
            {
               gatherSpeech();
            }
        });
        
        result = (TextView)findViewById(R.id.tv_result);
    }
    
    @Override
    public void onUtteranceCompleted(String utteranceId)
    {
        //done speaking, execute some ui updates on the UIthread
    }
    
    public void receiveWhatWasHeard(List<String> lastThingsHeard)
    {
        if (lastThingsHeard.size() == 0)
        {
            speaker.say("Heard nothing", this);
            result.setText("Nothing heard.");
        }
        else
        {
            String mostLikelyThingHeard = lastThingsHeard.get(0);
            String magicWord = this.getResources().getString(R.string.magicword);
            int levenshteinDistance = getLevenshteinDistance(magicWord, mostLikelyThingHeard);
            if (mostLikelyThingHeard.equals(magicWord))
            {
                speaker.say("You said the magic word!", this);
            }
            else
            {
            	String message = "You guessed " + mostLikelyThingHeard + ", which is " + levenshteinDistance + " letters off.";
                //speaker.say("It's not " + mostLikelyThingHeard + " try again", this);
                speaker.say(message, this);
                result.setText(message);
            }
        }
        //result.setText("heard: " + lastThingsHeard);
    }

    /**
     * Return Levenshtein distance between two strings.
     * From http://www.merriampark.com/ldjava.htm
     */
	public static int getLevenshteinDistance(String s, String t) {
		if (s == null || t == null) {
			throw new IllegalArgumentException("Strings must not be null");
		}

		/*
		 * The difference between this impl. and the previous is that, rather
		 * than creating and retaining a matrix of size s.length()+1 by
		 * t.length()+1, we maintain two single-dimensional arrays of length
		 * s.length()+1. The first, d, is the 'current working' distance array
		 * that maintains the newest distance cost counts as we iterate through
		 * the characters of String s. Each time we increment the index of
		 * String t we are comparing, d is copied to p, the second int[]. Doing
		 * so allows us to retain the previous cost counts as required by the
		 * algorithm (taking the minimum of the cost count to the left, up one,
		 * and diagonally up and to the left of the current cost count being
		 * calculated). (Note that the arrays aren't really copied anymore, just
		 * switched...this is clearly much better than cloning an array or doing
		 * a System.arraycopy() each time through the outer loop.)
		 * 
		 * Effectively, the difference between the two implementations is this
		 * one does not cause an out of memory condition when calculating the LD
		 * over two very large strings.
		 */

		int n = s.length(); // length of s
		int m = t.length(); // length of t

		if (n == 0) {
			return m;
		} else if (m == 0) {
			return n;
		}

		int p[] = new int[n + 1]; // 'previous' cost array, horizontally
		int d[] = new int[n + 1]; // cost array, horizontally
		int _d[]; // placeholder to assist in swapping p and d

		// indexes into strings s and t
		int i; // iterates through s
		int j; // iterates through t

		char t_j; // jth character of t

		int cost; // cost

		for (i = 0; i <= n; i++) {
			p[i] = i;
		}

		for (j = 1; j <= m; j++) {
			t_j = t.charAt(j - 1);
			d[0] = j;

			for (i = 1; i <= n; i++) {
				cost = s.charAt(i - 1) == t_j ? 0 : 1;
				// minimum of cell to the left+1, to the top+1, diagonally left
				// and up +cost
				d[i] = Math.min(Math.min(d[i - 1] + 1, p[i] + 1), p[i - 1]
						+ cost);
			}

			// copy current distance counts to 'previous row' distance counts
			_d = p;
			p = d;
			d = _d;
		}

		// our last action in the above loop was to switch d and p, so p now
		// actually has the most recent cost counts
		return p[n];
	}
}