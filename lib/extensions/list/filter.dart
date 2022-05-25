
// allows to filter a stream of list
extension Filter<T> on Stream<List<T>> {
  // bool function get the list of items and return true or false
  // if the some thing is passed the test, then it will be included in the final list
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
