import 'dart:io';

Socket? socket;
var videoList = [
  {'url': 'test-video-1.mp4', 'desc': 'Lincoln Uni', 'name': 'Wenbo Liu'},
  {'url': 'test-video-2.mp4', 'desc': 'NZ National', 'name': 'National'},
  {'url': 'test-video-3.mp4', 'desc': 'Lovely Dogs', 'name': 'Dog Lover'},
  {'url': 'test-video-4.mp4', 'desc': 'Cats', 'name': 'Cat Lover'},
  {'url': 'test-video-5.mp4', 'desc': 'All Blacks', 'name': 'All Blacks'},
  {'url': 'test-video-6.mp4', 'desc': 'Kea!!!!!!!!!!!', 'name': 'NZ Birds'},
  {'url': 'test-video-7.mp4', 'desc': 'Nice surfing day', 'name': 'Surfer'},
  {'url': 'test-video-8.mp4', 'desc': 'Dancing!!!!!!!', 'name': 'Dance girls'},
  {'url': 'test-video-9.mp4', 'desc': 'Dream Car', 'name': 'Dream Car'},
  {'url': 'test-video-10.mp4', 'desc': 'GOALLLLLLL!', 'name': 'Real Madrid'},
];

class UserVideo {
  final String url;
  final String image;
  final String? desc;
  final String? username;

  UserVideo({
    required this.url,
    required this.image,
    this.desc,
    this.username,
  });

  static List<UserVideo> fetchVideo() {
    List<UserVideo> list = videoList
        .map((e) => UserVideo(
              image: '',
              url: 'https://storage.googleapis.com/video999/${e['url']}',
              desc: '${e['desc']}',
              username: '${e['name']}',
            ))
        .toList();
    return list;
  }

  @override
  String toString() {
    return 'image:$image' '\nvideo:$url';
  }
}
