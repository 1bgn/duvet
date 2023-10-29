class Hyphenator{
  final String x = "йьъ";
  final String g = "аеёиоуыэюяaeiouy";
  final String s = "бвгджзклмнпрстфхцчшщbcdfghjklmnpqrstvwxz";
  final List rules = [];
  Hyphenator() {


    rules.add( HyphenPair("xgg", 1));
    rules.add( HyphenPair("xgs", 1));
    rules.add( HyphenPair("xsg", 1));
    rules.add( HyphenPair("xss", 1));
    rules.add( HyphenPair("gssssg", 3));
    rules.add( HyphenPair("gsssg", 3));
    rules.add( HyphenPair("gsssg", 2));
    rules.add( HyphenPair("sgsg", 2));
    rules.add( HyphenPair("gssg", 2));
    rules.add( HyphenPair("sggg", 2));
    rules.add( HyphenPair("sggs", 2));
  }
  // List<String >split(String original, String separator) {
  //   original = original.trim();
  //   List nodes =  [];
  //   int index = original.indexOf(separator);
  //   int i = 0;
  //   while (index >= 0) {
  //     nodes.add(original.substring(0, index));
  //     original = original.substring(index + separator.length);
  //     index = original.indexOf(separator);
  //     i++;
  //   }
  //   nodes.add(original);
  //   List<String> result = List(nodes.length);
  //   if (nodes.length > 0) {
  //     for (int loop = 0; loop < nodes.length; loop++) {
  //       result[loop] =  nodes.elementAt(loop);
  //     }
  //
  //   }
  //   return result;
  // }
   String hyphenate(String text, {String hyphenateSymbol="\u00ad"}) {

    StringBuffer sb =  StringBuffer();
    for(int i = 0; i < text.length; i++) {
      String c = text[i];
      if (x.indexOf(c) != -1) {
        sb.write("x");
      } else if (g.indexOf(c) != -1) {
        sb.write("g");
      } else if (s.indexOf(c) != -1) {
        sb.write("s");
      } else {
        sb.write(c);
      }
    }
    String hyphenatedText = sb.toString();
    String splitter = "┼";

    for(int i = 0; i < rules.length; i++) {
      HyphenPair hp = rules.elementAt(i);
      int index = hyphenatedText.indexOf(hp.pattern);
      while(index != -1) {
        int actualIndex = index + hp.position;
        hyphenatedText = hyphenatedText.substring(0, actualIndex) + splitter + hyphenatedText.substring(actualIndex);
        text = text.substring(0, actualIndex) + splitter + text.substring(actualIndex);
        index = hyphenatedText.indexOf(hp.pattern);
      }
    }
    List<String> parts = text.split( splitter);
    StringBuffer result = new StringBuffer();
    for(int i = 0; i < parts.length; i++) {
      String value = parts[i];
      result.write(hyphenateSymbol+value);
      //      result.write(value+hypnateSymbol);

    }

    String res = result.toString();
    // res = res.replaceAll("!\u00ad", "!");
    // res = res.replaceAll(".\u00ad", ".");


    return res.replaceFirst("\u00ad", "");
  }
}
class HyphenPair {
  final String pattern;
  final int position;

  HyphenPair(this.pattern, this.position);
}