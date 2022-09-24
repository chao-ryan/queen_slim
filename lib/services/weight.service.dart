import 'package:get/get.dart';
import 'package:queen_slim/models/weight.dart';
import 'package:queen_slim/services/index.dart';
import 'package:queen_slim/utils/index.dart';

class WeightService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();
  final Rx<Weight> _weightOfToday = Weight().obs;
  final RxList<Weight> _weights = <Weight>[].obs;

  Weight get weightOfToday => _weightOfToday.value;
  List<Weight> get weights => _weights;

  set weightOfToday(Weight weight) {
    _weightOfToday.value = weight;
  }

  set weights(List<Weight> value) {
    _weights.value = value;
  }

  Future<WeightService> initialize() async {
    final weightsFromStorage = _storageService.weights;
    final today = DateUtil.todayFormat();
    if (weightsFromStorage.isNotEmpty) {
      // 本地有缓存时，从localStorage取出
      _weights.value = weightsFromStorage;
      _weightOfToday.value = _weights.firstWhere((item) => item.date == today);
    } else {
      // 本地没有缓存时，开发阶段暂时先默认一个值
      _weightOfToday.value = Weight(date: today, weight: 50.0);
      _weights.value = [_weightOfToday.value];
    }
    return this;
  }

  add(double value) {
    final weight = Weight(date: DateUtil.todayFormat(), weight: value);
    _weights.add(weight);
    _sync();
  }

  _sync() {
    // 保存最新数据到localStorage
    _storageService.weights = _weights;
  }
}
