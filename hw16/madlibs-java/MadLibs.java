/*
madlibs.java
Author: Gabe B-W
HW16: Mad Libs program (in Java)
Parses ARGV[0] as a Mad Libs template file and asks user for words to fill in
the blanks. 

Format of the template file:
((...)) = placeholder, e.g.
>> Our favorite language is ((a gemstone)).
Then this program asks for "a gemstone". Please use a/an in the query.

To reuse an answer, use ((label:query)) the first time, then later ((label)) to
reuse the results of query. labels must match \w, i.e. [0-9A-Za-z_].
>> Our favorite language is ((gem:a gemstone)). We think ((gem)) is better than
((a gemstone))
In this case, the "gem" label is set to the result of the first query, then
reused at "((gem))"
*/

import java.util.*;
import java.util.regex.*;
import java.io.*;

class MadLibs {
  // Store value of a label like ((label:query))
  private HashMap<String,String> labels;
  private Pattern splitterRegex;
  private Scanner console;
  private String template; // the madlibs template string
  
  public static void main(String[] args){
    String fileName = null;
    if( args.length > 0 ){
      // User provided filename.
      fileName = args[0];
    }
    MadLibs madLibs = new MadLibs(fileName);
    
    System.out.println(madLibs.parse());
  }
  
  // Constructor that passes null as the fileName, which makes the program
  // prompt the user for a filename.
  public MadLibs(){
    this(null);
  }
  public MadLibs(String fileName){
    this.console = new Scanner(System.in);
    
    if( fileName == null ){
      // Prompt the user for a filename.
      System.out.print("Please enter a filename: ");
      fileName = console.next();
    }
    
    // make sure file is readable
    File file = new File(fileName);
    if( ! file.canRead() ){
      System.out.println("Can't read " + fileName + ".");
      // Prompt the user for a filename.
      System.out.print("Please enter a filename: ");
      fileName = console.next();
      file = new File(fileName);
      if( ! file.canRead() ){
        // REALLY can't read file.
        System.out.println("Can't read " + fileName + ", exiting.");
        System.exit(1);
      }
    }
    
    try {
      this.template = readFileToString(file);
    } catch(FileNotFoundException fnfe){
      System.out.println("File not found!");
      System.exit(1);
    }
    // label => answer
    this.labels = new HashMap<String,String>();
    // Use (?s) to get Pattern.DOTALL. Embed in the regex itself so that
    // matcher.pattern.toString() [below] keeps the options.
    this.splitterRegex = Pattern.compile("(?s)\\({2}(?:(\\w+?):)?(.+?)\\){2}");
  }
  
  public String parse(){
    Matcher matcher = splitterRegex.matcher(this.template);
    String replacedTemplate = this.template;
    
    while( matcher.find() ){
      String label = matcher.group(1); // may be null
      String query = matcher.group(2);
      String answer = "";
      // if no label, check if query IS a label
      if( label == null && this.labels.containsKey(query) ){
        answer = this.labels.get(query);
      } else {
        // When asking for input, use spaces for newlines
        System.out.print("Please give me " + query.replaceAll("\n", " ") + ": ");
        answer = console.next();
        System.out.println();
        // associate label with answer if label given
        if( label != null ){
          this.labels.put(label, answer);
        }        
      }
      replacedTemplate = replacedTemplate.replaceFirst(matcher.pattern().toString(), answer);
    }
    return replacedTemplate;
  }
  
  // Return contents of this.file as a String. Not particularly memory-efficient.
  public String readFileToString(File file) throws FileNotFoundException {
    String NL = System.getProperty("line.separator");
    Scanner scanner = new Scanner(file);
    String text = "";
    
    try {
      while (scanner.hasNextLine()){
        text += scanner.nextLine() + NL;
      }
    }
    finally{
      scanner.close();
    }
    return text;
  }
}