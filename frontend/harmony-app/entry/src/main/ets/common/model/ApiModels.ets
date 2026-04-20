export interface ApiResponse<T> {
  code: number
  message: string
  data: T
  timestamp: string
}

export type UserRole =
  | 'VISITOR'
  | 'ADMIN'
  | 'COMPLAINT_HANDLER'
  | 'EMERGENCY_WRITER'
  | 'APPROVER'
  | 'HOTEL_MANAGER'
  | 'SYSTEM_ADMIN'

export interface LoginRequest {
  username: string
  password: string
}

export interface LoginResponse {
  token: string
  username: string
  displayName: string
  role: UserRole | string
}

export interface RegisterRequest {
  username: string
  password: string
  displayName: string
}

export interface RegisterResponse {
  username: string
  displayName: string
  role: UserRole | string
}

export interface RequestResetCodeRequest {
  username: string
}

export interface RequestResetCodeResponse {
  username: string
  debugCode: string
  expiresAt: string
}

export interface ResetPasswordRequest {
  username: string
  code: string
  newPassword: string
}

export interface CurrentUser {
  username: string
  displayName: string
  role: UserRole | string
}

export interface ComplaintItem {
  id: number
  title: string
  content: string
  attachmentUrls: string | null
  status: string
  handlerComment: string | null
  closureComment: string | null
  rejectionComment: string | null
  rating: number | null
  createdBy: string
  processedBy: string | null
  assignee: string | null
  createdAt: string
  updatedAt: string
}

export interface ComplaintCreateRequest {
  title: string
  content: string
  attachmentUrls?: string
}

export interface ComplaintActionRequest {
  comment: string
}

export interface ComplaintAssignRequest {
  assigneeUsername: string
  comment?: string
}

export interface ComplaintRatingRequest {
  rating: number
}

export interface ComplaintTimelineItem {
  id: number
  action: string
  comment: string | null
  actor: string | null
  createdAt: string
}

export interface ComplaintQueryFilter {
  status: string
  createdBy: string
  assignee: string
  keyword: string
  from: string
  to: string
}

export interface EmergencyItem {
  id: number
  title: string
  content: string
  status: string
  validFrom: string | null
  validUntil: string | null
  alertLevel?: string
  alertType?: string
  createdBy: string
  approvedBy: string | null
  createdAt: string
  updatedAt: string
}

export interface EmergencyRequest {
  title: string
  content: string
  validFrom: string | null
  validUntil: string | null
  alertLevel?: string
  alertType?: string
}

export interface HotelResponse {
  id: string
  name: string
  address: string
  star: number
  price: number
  phone: string
  score: number
  hasBreakfast: boolean
  facility: string
  introduction: string
  availabilityStatus?: string
  coverImageUrl?: string
}

export interface ScenicSpotResponse {
  id: string
  name: string
  scenicArea: string
  location: string
  openTime: string
  ticketPrice: number
  level: string
  type: string
  isFree: boolean
  description: string
  crowdHeat?: number
  coverImageUrl?: string
}

export interface TravelRouteResponse {
  id: string
  name: string
  durationHours: number
  difficulty: string
  suitableFor: string
  spots: string
  detail: string
}

export interface DiningResponse {
  id: string
  name: string
  type: string
  avgPrice: number
  businessHours: string
  address: string
  recommendFood: string
  detailDesc: string
  logoUrl?: string
  distanceMeters?: number
  isOpen?: boolean
  navLat?: number
  navLng?: number
}

export interface EntertainmentResponse {
  id: string
  name: string
  type: string
  location: string
  openTime: string
  price: number
  description: string
  logoUrl?: string
  distanceMeters?: number
  isOpen?: boolean
  navLat?: number
  navLng?: number
}

export interface PerformanceResponse {
  id: string
  name: string
  location: string
  showTime: string
  price: number
  team: string
  detail: string
  venue?: string
  showDateTime?: string
  remainingTickets?: number
  ticketStatus?: string
  distanceMeters?: number
  navLat?: number
  navLng?: number
}

export interface WeatherResponse {
  date: string
  weather: string
  temperature: string
  wind: string
  humidity: number
  tip: string
}

export interface TrafficResponse {
  fromLocation: string
  toLocation: string
  status: string
  suggestRoute: string
  takeTime: string
  severityLevel?: string
}
