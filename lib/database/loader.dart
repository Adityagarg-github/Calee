// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/database/local_db.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:intl/intl.dart';
import 'event.dart';

class Loader {
  static String convertTo24(String time, String segment) {
    int hour = int.parse(time.split('.')[0]);
    int min = int.parse(time.split('.')[1]);
    if (segment.toLowerCase().compareTo('am') != 0) {
      if (hour != 12) hour += 12;
    } else if (hour == 12) {
      hour = 0;
    }
    return '${hour.toString().padLeft(2, "0")}:${min.toString().padLeft(2, "0")}';
  }

  static Map<String, String>? courseToSlot;
  static Map<String, String>? courseToProff;
  static Map<String, List<String>>? slotToTime;

  static Future<void> loadSlots() async {
    void listFiles() async {
      final ListResult result = await FirebaseStorage.instance.ref().listAll();
      for (var item in result.items) {
        print("Found file: ${item.name}");
      }
    }


    print("hello");
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child('CourseSlots.csv');

    try {
      final Uint8List? csvData = await ref.getData(10 * 1024 * 1024);
      (print(csvData?.length));
      print(csvData);
      if (csvData != null && csvData.isNotEmpty) {
        print("Raw CSV Data (first 100 bytes): ${csvData.sublist(0, csvData.length)}");
      } else {
        print("CSV Data is empty or null");
      }


      if (csvData != null) {
        // Decode CSV data into a String
        final String decodedData = utf8.decode(csvData, allowMalformed: true);
        //final String decodedData = utf8.decode(csvData);
        print("Successfully fetched CourseSlots.csv");
        print("Decoded CSV String Length: ${decodedData.length}");
        List<String> lines = decodedData.split("\n");

        for (int i = 0; i < lines.length; i++) {
          print("Line $i: ${lines[i]}");
        }
        // for (int i = 0; i < decodedData.length; i += 500) {
        //   print(decodedData.substring(i, i + 500 > decodedData.length ? decodedData.length : i + 500));
        // }
          //print(decodedData);
        // Parse CSV string into a list of lists
        List<List<dynamic>> courseSlots = const CsvToListConverter( eol: "\n",
          fieldDelimiter: ",",).convert(
            decodedData);
        // print(courseSlots);

        courseToSlot = {};
        courseToProff = {};

        for (final slot in courseSlots) {
          if (slot[0].runtimeType == int) {
            final courseName = slot[1].toString().replaceAll(' ', '');
            courseToSlot![courseName] = slot[3];
            courseToProff![courseName] = slot[6];
          }
        }
        // print(courseToSlot);
        // print(courseToProff);
      }
    }
    catch (e) {
      print('Error loading CSV file: $e');
    }
  }

  static Future<void> loadTimes() async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child('TimeTable.csv');

    try {
      // Try to download the CSV file as a byte stream
      final Uint8List? csvData = await ref.getData();
      if (csvData != null) {
        // Decode CSV data into a String
        final String decodedData = utf8.decode(csvData);
        // Parse CSV string into a list of lists
        List<List<dynamic>> slotTimes = const CsvToListConverter(eol:'\n').convert(decodedData);
        var len = slotTimes.length;
        print("Time Table");
        print(slotTimes);

        slotToTime = {};

        List<String> timings = slotTimes[0].cast<String>();
        for (int i = 1; i < timings.length; i++) {
          List<String> tokens = timings[i].split(' ');
          if (tokens.length != 4) continue;
          timings[i] =
              '${convertTo24(tokens[0], tokens[3])}|${convertTo24(tokens[2], tokens[3])}'
                  .toLowerCase();
        }

        for (int i = 1; i < len; i++) {
          int sz = slotTimes[i].length;
          String weekday = slotTimes[i][0];
          weekday = weekday.toLowerCase();

          for (int j = 1; j < sz; j++) {
            String slot = slotTimes[i][j].replaceAll(' ', '');
            if (slotToTime![slot] == null) {
              slotToTime![slot] = List.empty(growable: true);
            }
            slotToTime![slot]!.add('$weekday|${timings[j]}');
          }
        }
      }
    } catch (e) {
      print('Error loading CSV file: $e');
    }
  }

  static Future<bool> saveCourses(List<String> course_id) async {
    print("yeah");
    print(course_id);
    
    EventDB().deleteOf("course");

    //  Preprocess
    for (int i = 0; i < course_id.length; i++) {
      course_id[i] = course_id[i].replaceAll(' ', '');
    }

    if (courseToSlot == null) {
      await loadSlots();
    }
    print("loaded Times");
    await loadTimes();
    // if (slotToTime == null) {
    //   await loadTimes();
    // }

    semesterDur sd = await firebaseDatabase.getSemDur();


    for (int i = 0; i < course_id.length; i++) {
      await saveExtraClasses(course_id[i]);
      for (int j = 0; j < 2; j++) {
        String? slot = courseToSlot![course_id[i]];
        //  Processes as Tutorial or Class
        slot = (j == 0) ? (slot) : ('T-$slot');
        String title = course_id[i];
        String host = courseToProff![course_id[i]].toString();
        String desc = (j == 0) ? 'Class' : 'Tutorial';

        List<String>? times = slotToTime![slot];
        if (times == null) continue;

        for (int j = 0; j < times.length; j++) {
          var l = times[j].split('|');
          String day = l[0];
          int mask = 0;
          const weekdays = [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday'
          ];
          for (int k = 0; k < 7; k++) {
            if (day.compareTo(weekdays[k]) == 0) {
              mask = 1 << k;
              break;
            }
          }

          String stime = l[1];
          String etime = l[2];
          Event e = Event(
            title: title,
            desc: desc,
            stime: str2tod(stime),
            etime: str2tod(etime),
            creator: 'course',
            venue: 'M6, LHC',
            host: host
          );
          try {
            await EventDB().addRecurringEvent(
              e,
              sd.startDate!,
              sd.endDate!,
              mask,
            );
          } catch (e) {
            continue;
          }
        }
      }
    }

    return true;
  }

  static Future<void> loadMidSem(
    TimeOfDay morningSlot_start,
    TimeOfDay morningSlot_end,
    TimeOfDay eveningSlot_start,
    TimeOfDay eveningSlot_end,
    List<String> courses,
  ) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child('MidSemTable.csv');

    if (courseToSlot == null) {
      await loadSlots();
    }
    try{
      print("midsem");
      // Try to download the CSV file as a byte stream
      final Uint8List? csvData = await ref.getData();
      print("Midsem Csv successful");
      if (csvData != null) {
        print(csvData.length);
        // Decode CSV data into a String
        final String decodedData = utf8.decode(csvData);
        // Parse CSV string into a list of lists
        List<List<dynamic>> exams = const CsvToListConverter().convert(
            decodedData);

        //print(exams);

        Map<String, String> slotToDay = {};
        for (int i = 0; i < exams.length; i++) {
          if (exams[i].length != 3) {
            print("error midsem csv");
            throw ArgumentError("Invalid CSV");
          }
          DateTime startDate = DateFormat('dd-MM-yyyy').parse(exams[i][0]);
          List<String> courses1 = exams[i][1].split('|');
          print("courses1");
          print(courses1);
          for(int j=0;j<courses1.length;j++){
            slotToDay[courses1[j]]="${dateString(startDate)}|${tod2str(morningSlot_start)}|${tod2str(morningSlot_end)}";
          }

          List<String> courses2 = exams[i][2].split('|');
          for(int j=0;j<courses2.length;j++){
            slotToDay[courses2[j]]="${dateString(startDate)}|${tod2str(eveningSlot_start)}|${tod2str(eveningSlot_end)}";
          }
        }
        print(slotToDay);

        for (int i = 0; i < courses.length; i++) {
          if(!slotToDay.containsKey(courses[i]))continue;
          var l = slotToDay[courses[i]]!.split('|');
          var e = Event(
              title: 'Mid-Semester Examinations',
              desc: courses[i],
              stime: str2tod(l[1]),
              etime: str2tod(l[2]),
              creator: 'Exam');
          print("mid sem schedule");
          print(e.desc);
          EventDB().addSingularEvent(e, stringDate(l[0]));
        }
      }
    }catch(e){
    }
  }

  static Future<void> loadEndSem(
    TimeOfDay morningSlot_start,
    TimeOfDay morningSlot_end,
    TimeOfDay eveningSlot_start,
    TimeOfDay eveningSlot_end,
    List<String> courses,
  ) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child('EndSemTable.csv');

    if (courseToSlot == null) {
      await loadSlots();
    }
    try{
      // Try to download the CSV file as a byte stream
      final Uint8List? csvData = await ref.getData();
      if (csvData != null) {
        // Decode CSV data into a String
        final String decodedData = utf8.decode(csvData);
        // Parse CSV string into a list of lists
        List<List<dynamic>> exams = const CsvToListConverter().convert(
            decodedData);

        Map<String, String> slotToDay = {};
        for (int i = 0; i < exams.length; i++) {
          if (exams[i].length != 3) {
            throw ArgumentError("Invalid CSV");
          }
          DateTime startDate = DateFormat('dd-MM-yyyy').parse(exams[i][0]);
          List<String> courses1 = exams[i][1].split('|');
          for(int j=0;j<courses1.length;j++){
            slotToDay[courses1[j]]="${dateString(startDate)}|${tod2str(morningSlot_start)}|${tod2str(morningSlot_end)}";
          }

          List<String> courses2 = exams[i][2].split('|');
          for(int j=0;j<courses2.length;j++){
            slotToDay[courses2[j]]="${dateString(startDate)}|${tod2str(eveningSlot_start)}|${tod2str(eveningSlot_end)}";
          }
        }
        print("endsem");
        print(slotToDay);
        for (int i = 0; i < courses.length; i++) {
          if(!slotToDay.containsKey(courses[i]))continue;
          var l = slotToDay[courses[i]]!.split('|');
          var e = Event(
              title: 'End-Semester Examinations',
              desc: courses[i],
              stime: str2tod(l[1]),
              etime: str2tod(l[2]),
              creator: 'Exam');
          EventDB().addSingularEvent(e, stringDate(l[0]));
        }
      }
    }catch(e){
    }
  }

  static Future<List<ExtraClass>> loadExtraClasses(String course) async {
    return firebaseDatabase.getExtraClass(course);
  }

  static Future<void> saveExtraClasses(String course_id) async {
    List<ExtraClass> extraclasses =
        await firebaseDatabase.getExtraClass(course_id);

    for (ExtraClass c in extraclasses) {
      Event e = Event(
        title: c.courseID,
        desc: c.description,
        stime: c.startTime,
        etime: c.endTime,
        venue: c.venue,
        host: courseToProff![c.courseID].toString(),
        creator: 'course',
      );
      await EventDB().addSingularEvent(e, c.date);
    }
  }
}
