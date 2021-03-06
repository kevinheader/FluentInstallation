﻿using System.IO;
using Xunit;

namespace FluentInstallation.Web.Administration
{
    public class VirtualDirectoryConfigurerTests
    {
        
        [Fact]
        public void UseAlias_SetsThePath()
        {
            var virtualDirectory = WebAdministrationFactory.CreateVirtualDirectory();
            var sut = new VirtualDirectoryConfigurer(virtualDirectory);

            sut.UseAlias("/mySite");

            Assert.Equal("/mySite", virtualDirectory.Path);
        }

        [Fact]
        public void UseAlias_SetsThePathWhenTheAliasHasNoForwardSlash()
        {
            var virtualDirectory = WebAdministrationFactory.CreateVirtualDirectory();
            var sut = new VirtualDirectoryConfigurer(virtualDirectory);

            sut.UseAlias("mySite");

            Assert.Equal("/mySite", virtualDirectory.Path);
        }

        [Fact]
        public void OnPhysicalPath_SetsThePhysicalPath()
        {
            var virtualDirectory = WebAdministrationFactory.CreateVirtualDirectory();
            var sut = new VirtualDirectoryConfigurer(virtualDirectory);

            sut.OnPhysicalPath("C:\\");

            Assert.Equal("C:\\", virtualDirectory.PhysicalPath);
        }

        [Fact]
        public void OnPhysicalPath_ThrowsIfPathDoesNotExist()
        {
            var virtualDirectory = WebAdministrationFactory.CreateVirtualDirectory();
            var sut = new VirtualDirectoryConfigurer(virtualDirectory);

            Assert.Throws<DirectoryNotFoundException>(() => sut.OnPhysicalPath("C:\\mySite282829"));
            
        }
        
   }
}