import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:video_convert/objects/convertQueueEntry.dart';
import 'dart:io';

import 'package:video_convert/objects/dbsqlite.dart';
import 'package:video_convert/objects/fileEntry.dart';
import 'package:video_convert/views/combineByDayView.dart';

class QueueItemDetailView extends StatefulWidget {
  ConvertQueueEntry convertQueueEntry;
  DbSqlite db;
  QueueItemDetailView({Key key, this.convertQueueEntry, this.db})
      : super(key: key);

  @override
  _QueueItemDetailViewState createState() =>
      _QueueItemDetailViewState(this.convertQueueEntry);
}

class _QueueItemDetailViewState extends State<QueueItemDetailView> {
  TextEditingController sourcePathController = TextEditingController(text: "");
  TextEditingController targetPathController = TextEditingController(text: "");
  TextEditingController optionsPathController =
      TextEditingController(text: "-vf scale=320:-1");
  FilePickerCross sourceFile;
  bool deleteFile = false;
  List<FileEntry> filesFound = [];
  List<String> datesFound = [];

  _QueueItemDetailViewState(ConvertQueueEntry convertQueueEntry) {
    if (convertQueueEntry == null) {
      print("it is null");
    } else {
      print("it is not null");

      sourcePathController.text = convertQueueEntry.sourceFile;
      targetPathController.text = convertQueueEntry.sourceFile;
      optionsPathController.text = convertQueueEntry.options;
      deleteFile = convertQueueEntry.delete;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.db == null) {
      print("QueueItemDetailView::build() - widget.db is null");
    }
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              title: Text('Queue Item Detail'),
              bottom: TabBar(tabs: [
                Tab(text: "Convert"),
                Tab(text: "Combine"),
              ])),
          body: TabBarView(children: [
            Container(
              child: Column(
                children: <Widget>[
                  MaterialButton(
                    child: Text("Select Source"),
                    minWidth: 200,
                    onPressed: () async {
                      FilePickerCross myFile =
                          await FilePickerCross.importFromStorage(
                              type: FileTypeCross
                                  .video, // Available: `any`, `audio`, `image`, `video`, `custom`. Note: not available using FDE
                              fileExtension:
                                  //'txt, md' // Only if FileTypeCross.custom . May be any file extension like `dot`, `ppt,pptx,odp`
                                  'mp4, m4v, mpg, mpeg');

                      print(myFile.directory);
                      print(myFile.fileName);

                      this.sourceFile = myFile;

                      sourcePathController.text =
                          myFile.directory + "/" + myFile.fileName;

                      var split_data = myFile.fileName.split(".");

                      //print(myFile.fileName
                      //.substring(0, myFile.fileName.lastIndexOf(".")));
                      //print(myFile.fileName.lastIndexOf("."));

                      //print(
                      //"${split_data[0]}-smaller.${split_data[split_data.length - 1]}");

                      targetPathController.text =
                          "${myFile.directory}/${myFile.fileName.substring(0, myFile.fileName.lastIndexOf("."))}-smaller.${split_data[split_data.length - 1]}";
                    },
                    color: Colors.blue,
                    textColor: Colors.white,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 20, bottom: 20, right: 20, left: 20),
                          child: TextField(
                            controller: this.sourcePathController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                hintText: "Source"),
                            enabled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 20, bottom: 20, right: 20, left: 20),
                          child: TextField(
                            controller: this.targetPathController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              hintText: "target",
                            ),
                            enabled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20),
                        width: 100,
                        child: Text(
                          "Options: ",
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 20, bottom: 20, right: 20),
                          child: TextField(
                            controller: this.optionsPathController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            enabled: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("Delete after convert")),
                      Switch(
                          value: this.deleteFile,
                          onChanged: (value) {
                            setState(() {
                              this.deleteFile = value;
                            });
                          })
                    ],
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                        child: Text("Add"),
                        minWidth: 200,
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.pop(
                              context,
                              ConvertQueueEntry(
                                sourceDir: this.sourceFile.directory,
                                sourceFile: this.sourceFile.fileName,
                                target: targetPathController.text,
                                options: optionsPathController.text,
                                delete: this.deleteFile,
                              ));
                        },
                      ),
                      MaterialButton(
                        child: Text("Cancel"),
                        minWidth: 200,
                        color: Colors.red,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
                child: Column(
              children: [
                MaterialButton(
                  child: Text("press it"),
                  minWidth: 200,
                  onPressed: () async {
                    var myDir = Directory('D:/Development/JDK/untitled folder');
                    List<FileSystemEntity> files = myDir.listSync();

                    if (widget.db != null) {
                      for (File file in files) {
                        try {
                          widget.db.insert(
                            file.path,
                            file.lastModifiedSync(),
                          );
                        } catch (exception) {
                          print(exception.toString());
                        }
                      }

                      //var temp =
                      //await widget.db.groupFilesByDateCreated("2021-07-07");

                      var uniqueDates = await widget.db.getUniqueDatesCreated();

                      /*List<FileEntry> groupedFiles = [];

                      for (String dateString in uniqueDates) {
                        groupedFiles.addAll(await widget.db
                            .groupFilesByDateCreated(dateString));
                      }*/

                      setState(() {
                        //this.filesFound = groupedFiles;
                        this.datesFound = uniqueDates;
                      });
                    } else {
                      print("widget.db is null");
                    }
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      //itemCount: filesFound.length,
                      itemCount: datesFound.length,
                      itemBuilder: (BuildContext context, int index) {
                        /*return Container(
                          height: 50,
                          //color: Colors.amber[colorCodes[index]],
                          child: Center(
                            child:
                                //Text('Entry ${filesFound[index].createDate}'),
                                Text('${datesFound[index]}'),
                          ),
                        );*/
                        return ListTile(
                          title: Text('${datesFound[index]}'),
                          onTap: () {
                            print("${datesFound[index]} was clicked");

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CombineByDateView(
                                  date: datesFound[index],
                                  db: widget.db,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            )),
          ]),
        ));

    ;
  }
}
