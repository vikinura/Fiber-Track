import userRepository from './users.repository.js';
import { ForbiddenError } from '../../utils/errors.js';

export class UserService {
  async getTechnicians(auth) {
    if (auth.role !== 'vendor_admin') {
      throw new ForbiddenError('Hanya vendor_admin yang dapat mengakses daftar teknisi vendor');
    }
    if (!auth.vendorId) {
      throw new ForbiddenError('Identitas vendor tidak ditemukan pada akun Anda');
    }
    return userRepository.findTechniciansByVendorId(auth.vendorId);
  }
}

export default new UserService();
