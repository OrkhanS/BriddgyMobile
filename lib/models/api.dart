class Api {
  static const String address = "http://briddgy.herokuapp.com/";
  static const currentUserDetails = address + "api/users/me/";
  static const signUp = address + "api/users/";
  static const login = address + "api/auth/";
  static const messages = address + "api/chat/messages/?room_id=";
  static const chats = address + "api/chats/";
  static const orders = address + "api/orders/";
  static const myOrders = address + "api/my/orders/";
  static const trips = address + "api/trips/";
  static const myTrips = address + "api/my/trips/";
}
