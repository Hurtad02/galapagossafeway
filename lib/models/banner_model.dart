
import 'package:cloud_firestore/cloud_firestore.dart';

class Banners {

  String title;
  String description;
  String thumbnailImagelUrl;
  String sourceUrl;
  String date;
  String timestamp;

  Banners({

    this.title,
    this.description,
    this.thumbnailImagelUrl,
    this.sourceUrl,
    this.date,
    this.timestamp

  });


  factory Banners.fromFirestore(DocumentSnapshot snapshot){
    var d = snapshot.data();
    return Banners(
      title: d['title'],
      description: d['description'],
      thumbnailImagelUrl: d['image url'],
      sourceUrl: d['source'],
      date: d['date'],
      timestamp: d['timestamp'],


    );
  }
}