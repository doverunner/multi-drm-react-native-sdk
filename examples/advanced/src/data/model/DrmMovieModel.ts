import { DrmMovie } from '../../domain/model/DrmMovie';

export class DrmMovieModel implements DrmMovie {
    url = '';
    contentId = '';
    title = '';
    token = '';
    licenseUrl = 'https://drm-license.doverunner.com/ri/licenseManager.do/';
    licenseCipherTablePath = '';
    certificateUrl = '';
    downloadState = '';
}
