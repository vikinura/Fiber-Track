import areaRepository from './areas.repository.js';
import odpRepository from './odps.repository.js';

export class MasterService {
  async getAreas(tenantId) {
    return areaRepository.findByTenantId(tenantId);
  }

  async getOdps(tenantId, areaId = null) {
    return odpRepository.findByTenantId(tenantId, areaId);
  }
}

export default new MasterService();
