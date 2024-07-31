import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../utils/constants.dart';
import '../../../utils/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(const TimerInitial(kTimerDuration)) {
    on<TimerStarted>(_onStarted);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<TimerReset>(_onReset);
    on<_TimerTicked>(_onTicked);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSubscription?.cancel();

    _tickerSubscription = _ticker
        .tick(ticks: event.duration)
        .listen((duration) => add(_TimerTicked(duration: duration)));
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void _onResumed(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(const TimerInitial(kTimerDuration));
  }

  void _onTicked(_TimerTicked event, Emitter<TimerState> emit) {
    if (event.duration > 0) {
      emit(TimerRunInProgress(event.duration));
    } else {
      emit(const TimerRunComplete());
    }
  }
}

// class TimerBloc extends Bloc<TimerEvent, TimerState> {
//   TimerBloc() : super(TimerInitial());

//   Timer? _timer;
//   int _seconds = 0;
//   final ScreenshotController screenshotController = ScreenshotController();

//   @override
//   Stream<TimerState> mapEventToState(TimerEvent event) async* {
//     if (event is StartTimer) {
//       _startTimer();
//       yield TimerRunning(_seconds);
//     } else if (event is StopTimer) {
//       _stopTimer();
//       yield TimerInitial();
//     } else if (event is CaptureScreenshot) {
//       final screenshotPath = await _captureScreenshot();
//       yield ScreenshotCaptured(screenshotPath);
//     }
//   }

//   void _startTimer() {
//     _timer?.cancel();
//     _seconds = 0;
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       _seconds++;
//       add(StartTimer()); // Update the state with new seconds
//     });
//   }

//   void _stopTimer() {
//     _timer?.cancel();
//   }

//   Future<String> _captureScreenshot() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/screenshot_${DateTime.now().toIso8601String()}.png';
//     await screenshotController.captureAndSave(path);
//     return path;
//   }
// }