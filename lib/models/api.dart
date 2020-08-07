class Api {
  static const String address = "http://34.68.255.37/";
  static const roomSocket = "ws://34.68.255.37/chat/";
  static const alertSocket = address + "ws/alert/?token=";
  static const currentUserDetails = address + "api/users/me/";
  static const signUp = address + "api/users/";
  static const users = address + "api/users/";
  static const login = address + "api/auth/";
  static const messages = address + "api/chat/messages/?room_id=";
  static const chats = address + "api/chats/";
  static const orders = address + "api/orders/";
  static const myOrders = address + "api/my/orders/";
  static const trips = address + "api/trips/";
  static const myTrips = address + "api/my/trips/";
  static const getSuggestions = address + "api/cities/?search=";
  static const contracts = address + "api/my/contracts/";
  static const itemConnectOwner = address + "api/chat/";
  static const userStats = address + "api/users/stats/";
  static const myStats = address + "api/users/my/stats/";
  static const myReviews = address + "api/users/my/reviews/";
  static const requestEmailVerification = address + "api/request/email/";
  static const verifyEmail = address + "api/request/verify/";
  static const orderById = address + "api/users/";
  static const forgetPassword = address + "api/request/password/";
  static const addOrderImage = address + "api/fileupload/orderimage/";
}
