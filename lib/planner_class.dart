import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:planner/events_painter.dart';
import 'package:planner/hour_container.dart';
import 'package:planner/manager.dart';
import 'package:planner/planner_date_pos.dart';
import 'package:planner/planner_entry.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';
import 'package:provider/provider.dart';

import 'date_container.dart';

class Planner<T> extends StatefulWidget {
  final Function(PlannerEntry<T>, ManagerProvider manager) onPlannerDoubleTap;
  final Function(PlannerEntry<T>, ManagerProvider manager) onEntryDoubleTap;
  final Function(PlannerEntry<T>, ManagerProvider manager) onEntryChanged;

  Planner({Key key, this.onEntryChanged, this.onEntryDoubleTap, this.onPlannerDoubleTap}) : super(key: key);

  @override
  _PlannerState createState() => _PlannerState();
}

class _PlannerState extends State<Planner> with AfterLayoutMixin<Planner> {
  ManagerProvider manager;
  GlobalKey _keyEventPainter = GlobalKey();
  Offset lastTapPos = Offset.zero;

  @override
  void afterFirstLayout(BuildContext context) {
    //Calculate Calendar Position
    final RenderBox eventBox = _keyEventPainter.currentContext.findRenderObject();
    manager.eventsPainterOffset = eventBox.localToGlobal(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    manager = Provider.of<ManagerProvider>(context);
    print("redraw calendar");
    return Column(
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 50.0,
              height: 50.0,
            ),
            // Day
            Expanded(
              child: ClipRect(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xff297fca),
                        width: 0.5,
                      ),
                    ),
                  ),
                  height: 50.0,
                  child: DateContainer(
                    manager: manager,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              // Hour Sidebar
              ClipRect(
                child: Container(
                  width: 50.0,
                  child: HourContainer(
                    manager: manager,
                  ),
                ),
              ),
              // Calendar
              Expanded(
                child: PositionedTapDetector(
                  onDoubleTap: (position) {
                    var entry = manager.getPlannerEntry(position.global);
                    if (entry == null) {
                      PlannerDatePos pos = manager.getPlannerDatePos(position.global);
                      final entry = PlannerEntry(
                        column: pos.column,
                        hour: pos.hour,
                        minutes: pos.minutes,
                        color: Colors.red,
                      );
                      if (widget.onPlannerDoubleTap != null) widget.onPlannerDoubleTap(entry, manager);
                    } else {
                      if (widget.onEntryDoubleTap != null) widget.onEntryDoubleTap(entry, manager);
                    }
                  },
                  child: GestureDetector(
                    onLongPressStart: (details) {
                      setState(() {
                        manager.touchPos = details.globalPosition;
                      });
                    },
                    onLongPressMoveUpdate: (details) {
                      setState(() {
                        manager.touchPos = details.globalPosition;
                      });
                    },
                    onLongPressEnd: (details) {
                      setState(() {
                        manager.touchPos = null;
                      });
                    },
                    child: Container(
                      key: _keyEventPainter,
                      child: CustomPaint(
                        painter: EventsPainter(manager: manager, onEntryChanged: widget.onEntryChanged),
                        child: Container(),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
