-- Класс Quaternion
Quaternion = {}
Quaternion.__index = Quaternion

-- Создание нового кватерниона
function Quaternion.new(w, x, y, z)
  local quat = {}
  setmetatable(quat, Quaternion)
  quat.w = w or 0
  quat.x = x or 0
  quat.y = y or 0
  quat.z = z or 0
  return quat
end

-- Нормализация кватерниона
function Quaternion:normalize()
  local length = math.sqrt(self.w * self.w + self.x * self.x + self.y * self.y + self.z * self.z)
  self.w = self.w / length
  self.x = self.x / length
  self.y = self.y / length
  self.z = self.z / length
end

-- Умножение кватернионов
function Quaternion:mul(other)
  local w = self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z
  local x = self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y
  local y = self.w * other.y - self.x * other.z + self.y * other.w + self.z * other.x
  local z = self.w * other.z + self.x * other.y - self.y * other.x + self.z * other.w
  return Quaternion.new(w, x, y, z)
end

-- Поворот кватерниона по углам Эйлера
function rotateQuaternionByEulerAngles(quaternion, eulerX, eulerY, eulerZ)
  -- Преобразование углов Эйлера в радианы
  local radX = math.rad(eulerX)
  local radY = math.rad(eulerY)
  local radZ = math.rad(eulerZ)

  -- Вычисление половинных углов
  local halfRadX = radX / 2
  local halfRadY = radY / 2
  local halfRadZ = radZ / 2

  -- Вычисление синусов и косинусов половинных углов
  local sinX = math.sin(halfRadX)
  local cosX = math.cos(halfRadX)
  local sinY = math.sin(halfRadY)
  local cosY = math.cos(halfRadY)
  local sinZ = math.sin(halfRadZ)
  local cosZ = math.cos(halfRadZ)

  -- Создание кватерниона из углов Эйлера
  local rotationQuaternion = Quaternion.new(cosY * cosX * cosZ + sinY * sinX * sinZ,
                                            sinY * cosX * cosZ - cosY * sinX * sinZ,
                                            cosY * sinX * cosZ + sinY * cosX * sinZ,
                                            cosY * cosX * sinZ - sinY * sinX * cosZ)

  -- Нормализация кватерниона поворота
  rotationQuaternion:normalize()

  -- Умножение исходного кватерниона на кватернион поворота
  local rotatedQuaternion = rotationQuaternion:mul(quaternion)

  -- Возвращение повернутого кватерниона
  return rotatedQuaternion
end
