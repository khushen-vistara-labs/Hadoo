enum ShuffleMode {
  off,
  songs,
  songsAndCategories,
  categories,
  random;

  bool get isActive => this != ShuffleMode.off;

}
