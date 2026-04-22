export interface ApiResponse<T> {
  code: number
  message: string
  data: T
  timestamp: string
}

export type UserRole =
  | 'VISITOR'
  | 'ADMIN'
  | 'APPROVER'
  | 'COMPLAINT_HANDLER'
  | 'HOTEL_ADMIN'
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
  permissions?: string[]
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
  permissions?: string[]
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
  permissions?: string[]
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
  totalRooms?: number
  availableRooms?: number
  marketingRecommended?: boolean
  marketingTag?: string
  marketingPriority?: number
  marketingNote?: string
}

export interface MarketingHotelItemResponse {
  id: string
  name: string
  address: string
  star: number
  price: number
  score: number
  hasBreakfast: boolean
  facility: string
  introduction: string
  availabilityStatus: string
  coverImageUrl?: string
  totalRooms?: number
  availableRooms?: number
  recommended: boolean
  marketingTag?: string
  marketingPriority: number
  marketingNote?: string
  areaLabel: string
}

export interface MarketingDashboardResponse {
  currentVisitors: number
  eastHeatPercent: number
  westHeatPercent: number
  loadLabel: string
  suggestion: string
  hotels: MarketingHotelItemResponse[]
}

export interface MarketingHotelUpdateRequest {
  recommended: boolean
  marketingTag?: string
  marketingPriority?: number
  marketingNote?: string
}

export interface SystemUserResponse {
  id: number
  username: string
  displayName: string
  role: UserRole | string
  enabled: boolean
  managedHotelId: string | null
  createdAt: string
  updatedAt: string
}

export interface SystemUserCreateRequest {
  username: string
  displayName: string
  role: UserRole | string
  password: string
  managedHotelId?: string
}

export interface SystemUserUpdateRequest {
  displayName: string
  role: UserRole | string
  managedHotelId?: string
}

export interface SystemUserResetPasswordRequest {
  newPassword: string
}

export interface AuditLogResponse {
  id: number
  actorUsername: string
  actorRole: string
  module: string
  action: string
  targetType: string
  targetId: string
  detail: string
  createdAt: string
}

export interface AuditLogPageResponse {
  items: AuditLogResponse[]
  total: number
  page: number
  size: number
}

export interface SystemSettingResponse {
  key: string
  value: string
  description: string
  updatedBy: string
  updatedAt: string
}

export interface SystemSettingUpdateRequest {
  value: string
  description?: string
}

export interface HotelAdminRequest {
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

export interface HotelRoomItemResponse {
  id: string
  name: string
  totalRooms: number
  availableRooms: number
  price: number
  imageUrl?: string
}

export interface HotelRoomItemRequest {
  id: string
  name: string
  totalRooms: number
  availableRooms: number
  price: number
  imageUrl?: string
}

export type ResourceApiCategory = 'SCENIC_SPOTS' | 'ROUTES' | 'DINING' | 'PERFORMANCES'

export interface ResourceItemRequest {
  title: string
  subtitle?: string
  location?: string
  schedule?: string
  description: string
  coverImageUrl?: string
  online?: boolean
  scenicArea?: string
  openTime?: string
  ticketPrice?: number
  level?: string
  type?: string
  isFree?: boolean
  crowdHeat?: number
  durationHours?: number
  difficulty?: string
  suitableFor?: string
  spots?: string
  avgPrice?: number
  businessHours?: string
  address?: string
  recommendFood?: string
  distanceMeters?: number
  isOpen?: boolean
  navLat?: number
  navLng?: number
  showTime?: string
  price?: number
  team?: string
  venue?: string
  showDateTime?: string
  remainingTickets?: number
  ticketStatus?: string
}

export interface ResourceItemResponse {
  id: string
  category: ResourceApiCategory | string
  title: string
  subtitle: string | null
  location: string | null
  schedule: string | null
  description: string
  coverImageUrl: string | null
  online: boolean
  updatedBy: string | null
  updatedAt: string | null
  scenicArea: string | null
  openTime: string | null
  ticketPrice: number | null
  level: string | null
  type: string | null
  isFree: boolean | null
  crowdHeat: number | null
  durationHours: number | null
  difficulty: string | null
  suitableFor: string | null
  spots: string | null
  avgPrice: number | null
  businessHours: string | null
  address: string | null
  recommendFood: string | null
  distanceMeters: number | null
  isOpen: boolean | null
  navLat: number | null
  navLng: number | null
  showTime: string | null
  price: number | null
  team: string | null
  venue: string | null
  showDateTime: string | null
  remainingTickets: number | null
  ticketStatus: string | null
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
