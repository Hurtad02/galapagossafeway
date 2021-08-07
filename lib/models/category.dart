
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {

  String name;
  String timestamp;
  String imageUrl;
  String date;

  Category({
    this.name,
    this.timestamp,
    this.imageUrl,
    this.date
  });


  factory Category.fromFirestore(DocumentSnapshot snapshot){
    var d = snapshot.data();
    return Category(
        name: d['name'],
        timestamp: d['timestamp'],
        imageUrl: d['image'],
        date: d['date']
    );
  }
}