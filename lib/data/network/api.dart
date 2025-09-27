class ApiUrl {
  static const String baseUrl = "https://vglkhiirjgiyarjebqpl.supabase.co";

  static const String supabaseAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZnbGtoaWlyamdpeWFyamVicXBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2MDMyOTEsImV4cCI6MjA1ODE3OTI5MX0.hp7KtDL7nZ_g9F_tjfqBQw0FKwk-G-tLtCLRG1r8PqE";

  // Base API
  static const String baseApi = "$baseUrl/rest/v1";

  // Table Endpoints
  static const String accessories = "$baseApi/accessories";
  static const String categories = "$baseApi/categories";
  static const String coaches = "$baseApi/coaches";
  static const String coachPlayers = "$baseApi/coachplayers";
  static const String devices = "$baseApi/devices";
  static const String exercises = "$baseApi/exercises";
  static const String matches = "$baseApi/matches";
  static const String players = "$baseApi/players";
  static const String training = "$baseApi/training";
  static const String trainingData = "$baseApi/trainingdata";
  static const String trainingSessions = "$baseApi/trainingsessions";
}

//* Header
// apikey: <anon_public_key>
// Authorization: Bearer <anon_public_key>
// Content-Type: application/json
