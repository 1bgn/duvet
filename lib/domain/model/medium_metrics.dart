class MediumMetrics{
  final int linesOnPage;
  final int pages;
  final int words;


  @override
  String toString() {
    return 'MediumMetrics{linesOnPage: $linesOnPage, pages: $pages, words: $words}';
  }

  MediumMetrics({required this.linesOnPage, required this.pages,required this.words});
}