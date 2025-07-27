import 'package:flutter/material.dart';

Widget buildOTHeader(BuildContext context) => Container(
  color: Colors.teal.shade200,
  padding: EdgeInsets.only(
    top: 12 + MediaQuery.of(context).padding.top,
    bottom: 12,
  ),
  child: const Column(
    children: [
      Text('New Testament',
          style: TextStyle(fontSize: 28, color: Colors.white)
      )
      // ExpansionTile(
      //     title: Text('Old Testament',
      //     style: TextStyle(fontSize: 28, color: Colors.white),
      //   ),
      // ),
    ],
  ),
);

Widget buildOTBooks(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    child: Wrap(
      children: [
        ListTile(
          title: const Text('Genesis'),
          onTap: () {
            Navigator.of(context).pop();
            // BooksLocalPage('Genesis');
          },
        ),
        // const Divider(color: Colors.black54),
        ListTile(
          title: const Text('Exodus'),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: const Text('Leviticus'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Numbers'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Deuteronomy'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Joshua'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Judges'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Ruth'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('1 Samuel'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('2 Samuel'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('1 Kings'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('2 Kings'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('1 Chronicles'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('2 Chronicles'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Ezra'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Nehemiah'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Esther'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Job'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Psalms'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Proverbs'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Ecclesiastes'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Song of Solomon'),
          onTap: () {},
        ),    ListTile(
          title: const Text('Isaiah'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Jeremiah'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Lamentations'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Ezekiel'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Daniel'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Hosea'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Joel'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Amos'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Obadiah'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Jonah'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Micah'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Nahum'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Habakkuk'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Zephaniah'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Haggai'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Zechariah'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Malachi'),
          onTap: () {},
        ),
      ],
    )
);

Widget buildNTHeader(BuildContext context) => Container(
  color: Colors.teal.shade200,
  padding: const EdgeInsets.only(
    top: 13,
    bottom: 12,
  ),
  child: const Column(
    children: [
      Text('New Testament',
          style: TextStyle(fontSize: 28, color: Colors.white)
      )
    ],
  ),
);

Widget buildNTBooks(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    child: Wrap(
      children: [
        ListTile(
          title: const Text('Matthew'),
          onTap: () {},
        ),
        // const Divider(color: Colors.black54),
        ListTile(
          title: const Text('Mark'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Luke'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('John'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Acts'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Romans'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('1 Corinthians'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('2 Corinthians'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Galatians'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Ephesians'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Philippians'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Colossians'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('1 Thessalonians'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('2 Thessalonians'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('1 Timothy'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('2 Timothy'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Titus'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Philemon'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Hebrews'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('James'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('1 Peter'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('2 Peter'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('1 John'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('2 John'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('3 John'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Jude'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('Revelation'),
          onTap: () {},
        ),
      ],
    )
);

