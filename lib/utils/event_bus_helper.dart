import 'package:event_bus/event_bus.dart';
import 'package:rubbish_detection/repository/data/order_bean.dart';

class EventBusHelper {
  static final EventBus eventBus = EventBus();
}

class UserInfoUpdateEvent {}

class OrderInfoUpdateEvent {
  final OrderBean? order;

  OrderInfoUpdateEvent(this.order);
}
