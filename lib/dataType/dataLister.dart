class dataLister {
  DLData header = DLData();

  addData(double order, var Data) {
    DLData temp = header;
    while (temp.next != null && temp.order < order) {
      temp = temp.next;
    }
    DLData nData = new DLData(data: Data, order: order);
    temp.next = nData;
    if (temp.next != null) nData.next = temp.next;
  }

  List returnList() {
    List ldata = [];
    DLData temp = header;
    while (temp != null) {
      ldata.add(temp.data);
      temp = temp.next;
    }
    return ldata;
  }
}

class DLData {
  var data = null;
  int order = 0;
  var next = null;

  DLData({data, next, order});
}
