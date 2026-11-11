import areaRepository from './areas.repository.js';
import odpRepository from './odps.repository.js';
import issueTypeRepository from './issue_types.repository.js';
import priorityRepository from './priorities.repository.js';

export class MasterService {
  async getAreas(tenantId) {
    return areaRepository.findByTenantId(tenantId);
  }

  async getOdps(tenantId, areaId = null) {
    return odpRepository.findByTenantId(tenantId, areaId);
  }

  async getIssueTypes(tenantId) {
    return issueTypeRepository.findByTenantId(tenantId);
  }

  async getPriorities(tenantId) {
    return priorityRepository.findByTenantId(tenantId);
  }
}

export default new MasterService();
